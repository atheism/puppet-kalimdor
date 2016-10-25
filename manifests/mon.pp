# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Li Tianqing <tianqing@unitedstack.com>
# Author: Yao Ning <yaoning@unitedstack.com>
#
# Initial Nodes with Daemon -- Ceph Monitor
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
# [*authentication_type*] Activate or deactivate authentication
#   Optional. Default to cephx.
#   Authentication is activated if the value is 'cephx' and deactivated
#   if the value is 'none'. If the value is 'cephx', at least one of
#   key or keyring must be provided.
#
# [*key*] Authentication key for [mon.]
#   Optional. $key and $keyring are mutually exclusive.

class kalimdor::mon (
  $cluster,
  $ensure               = present,
  $authentication_type  = 'cephx',
  $key                  = $::kalimdor::params::mon_key,
) {

    include kalimdor::options::mon
    $base_mon_options = $kalimdor::options::mon::mon_options

    $mon_id = $::hostname
    $mon_data =  "/var/lib/ceph/mon/${cluster}-${mon_id}"

    if $ensure == present {
        $base_mon_options.each |$key, $val| {

            # the first priority is ceph class
            $set_val = getvar("ceph::mon::$key")

            # the second priority is kalimdor::options::mon::mon_options class
            if $set_val {

                $really_val = $set_val
            } else {

                $really_val = $val
            }

            # set options in ceph.conf
            if $really_val {
                notify{"params: $key": message => "$really_val"}
                ceph_config {
                    "mon/${key}":   value => $really_val;
                }
            } else {
                ceph_config {
                    "mon/${key}":   ensure => absent;
                }
            }
        }
        ::ceph::mon { $mon_id:
            ensure                 => present,
            mon_enable             => true,
            cluster                => $cluster,
            authentication_type    => $authentication_type,
            key                    => $key,
        } -> 
        ceph::key { 'client.admin':
            secret  => $::kalimdor::params::admin_key,
            cluster => $cluster,
            keyring_path => "/etc/ceph/${cluster}.client.admin.keyring",
            cap_mon => 'allow *',
            cap_osd => 'allow *',
            cap_mds => 'allow *',
            user    => 'ceph',
            group   => 'ceph',
            inject         => true,
            inject_as_id   => 'mon.',
            inject_keyring => "/var/lib/ceph/mon/${cluster}-${mon_id}/keyring",
        }
    } else {
    #    $base_mon_options.each |$key, $val| {
    #        ceph_config {
    #            "mon/${key}":   ensure => absent;
    #        }
    #    }
        ::ceph::mon { $mon_id:
            ensure                 => absent,
            mon_enable             => false,
            cluster                => $cluster,
            authentication_type    => $authentication_type,
            key                    => $key,
        }
    }
}
