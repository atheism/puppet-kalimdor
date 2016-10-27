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

    $mon_id = $::hostname
    $mon_data =  "/var/lib/ceph/mon/${cluster}-${mon_id}"

    if $ensure == present {
        # set MON configs in ceph.conf
        include kalimdor::configs::mon
        
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
        ::ceph::mon { $mon_id:
            ensure                 => absent,
            mon_enable             => false,
            cluster                => $cluster,
            authentication_type    => $authentication_type,
            key                    => $key,
        }
    }
}
