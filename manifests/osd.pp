# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Li Tianqing <tianqing@unitedstack.com>
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::osd
#
# Init Nodes with Daemon -- Ceph OSD 

class kalimdor::osd (
  $cluster,
  $ensure                 = present,
  $osd_device_dict        = {},
  $bootstrap_osd_key      = ::kalimdor::params::osd_bootstrap_key,
  $enable_dangerous_operation = ::kalimdor::params::enable_dangerous_operation,
  $osd_disk_type              = undef, 
){
    include stdlib
    include ::kalimdor::params
    ceph::key { 'client.bootstrap-osd':
        secret  => $bootstrap_osd_key,
        cluster => $cluster,
        keyring_path => "/var/lib/ceph/bootstrap-osd/${cluster}.keyring",
        cap_mon => 'allow profile bootstrap-osd',
        user    => 'ceph',
        group   => 'ceph',
        inject => true,
    }

    #set osd configuration in ceph.conf
    case $osd_disk_type {
        ssd: {
            class { "kalimdor::configs::osd":
                host_osd_type      => 'fast', 
            }
        }
        sata: {
            class { "kalimdor::configs::osd":
                host_osd_type      => 'slow',
            }
        }
        mix: {
            class { "kalimdor::configs::osd":
                host_osd_type      => 'fast',
            }
        }
        default: {
            fail("This module does not support ${disk_type} disk type!")
        }
    }

    $osd_device_list = keys($osd_device_dict)
    $osd_device_list.each |$key| {

        $osd_data_wwn_name = $key
        $osd_data_name = $::wwn_dev_name_hash["$osd_data_wwn_name"]

        $items = split($osd_device_dict[$key], ':')
 
        $journal_device = $items[0]
        $present_item = $items[1]
        if !$enable_dangerous_operation {
            $enable_osd     = present
        } elsif size($items) == 2 and $items[1] == "absent" {
            $enable_osd     = absent
        } elsif $ensure == absent {
            $enable_osd     = absent
        } else {
            $enable_osd     = present
        }

#        notify{"$osd_data_name": 
#            message => "data_disk: $osd_data_name, journal_disk: $journal_device, status: $enable_osd"
#        }

        if $journal_device == '' {
            
            ceph::osd { $osd_data_name:
                ensure           => $enable_osd,
                cluster          => $cluster,
            }
        } else {

            $osd_journal_wwn = $journal_device
            $osd_journal_name = $::wwn_dev_name_hash[$osd_journal_wwn]

            ceph::osd { $osd_data_name:
                ensure           => $enable_osd,
                journal          => $osd_journal_name,
                cluster          => $cluster,
            }
        }

        if $enable_osd == absent {
            exec { "zap-osd-disk-${osd_data_name}":
                command          => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ceph-disk zap ${osd_data_name} &> /dev/null
",
                require          => Ceph::Osd[$osd_data_name],
            }   
        }  
    }
}
