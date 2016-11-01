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

    # set MON configs in ceph.conf
    include kalimdor::configs::mon

    ceph::mon { $mon_id:
        ensure                 => $ensure,
        mon_enable             => true,
        cluster                => $cluster,
        authentication_type    => $authentication_type,
        key                    => $key,
    }

    if $ensure == present {
        $keyring_path = "/etc/ceph/${cluster}.client.admin.keyring"
        $inject       = true
    } elsif $ensure == absent  {
        $keyring_path = undef
        $inject       = false
    } else {
        fail("ensure must be present or absent!")
    }

    ceph::key { 'client.admin':
            secret  => $kalimdor::params::admin_key,
            cluster => $cluster,
            keyring_path => $keyring_path,
            cap_mon => 'allow *',
            cap_osd => 'allow *',
            cap_mds => 'allow *',
            user    => 'ceph',
            group   => 'ceph',
            inject         => $inject,
            inject_as_id   => 'mon.',
            inject_keyring => "/var/lib/ceph/mon/${cluster}-${mon_id}/keyring",
    }

}
