# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Li Tianqing <tianqing@unitedstack.com>
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::osd
#
# Init Nodes with Daemon -- Ceph OSD
#
# === Parameters:
#
# [*cluster*] The ceph cluster's name
#   Mandatory. Defaults to 'ceph' Passed by init.pp
#
# [*ensure*] Installs ( present ) or remove ( absent ) a MON
#   Optional. Defaults to present.
#   If set to absent, it will stop the MON service and remove
#   the associated data directory.
#
# [*osd_devices*] Define devices which are used to make osds
#   Optional. Default to empty.
#
# [*osd_disk_type*] 


class kalimdor::osds (
  $cluster,
  $ensure                 = present,
  $osd_devices            = {},
  $osd_disk_type          = undef, 
){

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
            if $osd_disk_type {
                fail("This module does not support ${osd_disk_type} disk type!")
            } else {
                fail("Empty osd_disk_type is not allowed!")
            }
        }
    }

    validate_hash($osd_devices)
    $osd_devices.each |$key, $val| {

        $osd_data_wwn_name = $key
        $osd_data_name = $::wwn_dev_name_hash["$osd_data_wwn_name"]

        # before ':' is journal_device if defined
        # after  ':' is whether osd is present if defined
        $value_items = split($val, ':') 
        $journal_device = $value_items[0]
        $present_osd = $value_items[1]
        if size($items) == 2 and $present_osd == "absent" {
            $enable_osd     = absent
        } elsif $ensure == absent {
            $enable_osd     = absent
        } else {
            $enable_osd     = present
        }

        notify{"$osd_data_name": 
            message => "data_disk: $osd_data_name, journal_disk: $journal_device, status: $enable_osd"
        }

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
