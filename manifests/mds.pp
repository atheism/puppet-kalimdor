class kalimdor::mds (
  $mds_activate          = true,
  $cluster               = 'ceph',
  $mds_data              = '/var/lib/ceph/mds/$cluster-$id',
  $keyring               = '/var/lib/ceph/mds/$cluster-$id/keyring',
  $mds_name              = $::hostname,
  $host                  = $::hostname,
  $mds_key               = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',
) {

    $mds_keyring = "/var/lib/ceph/mds/$cluster-${host}"
    file { $mds_keyring:
        ensure => 'directory',
        owner  => 'ceph',
        group  => 'ceph'
    }

    ceph::key { "mds.${host}":
        secret       => $mds_key,
        cluster      => $cluster,
        cap_mon      => 'allow *',
        cap_osd      => 'allow *',
        cap_mds      => 'allow *',
        user         => 'ceph',
        group        => 'ceph',
        keyring_path => "/var/lib/ceph/mds/$cluster-${host}/keyring",
        inject       => true
    }

    Service {
      name   => "ceph-mds@${mds_name}",
      enable => $mds_activate,
    }

    class { "::ceph::mds":
        mds_activate          => $mds_activate,
        mds_data              => $mds_data,
        keyring               => $keyring,
    } ->

    ceph_config {
        "mds.${mds_name}/host":     value => $host;
        "mds.${mds_name}/mds_data": value => "/var/lib/ceph/mds/ceph-${mds_name}";
        "mds.${mds_name}/keyring":  value => "/var/lib/ceph/mds/ceph-${mds_name}/keyring";
    } ->

    service { $mds_name:
      ensure => $mds_activate,
      tag    => ['ceph-mds']
    }


    #service { "mds.${mds_name}":
    #    ensure => running,
    #    start  => "systemctl start ceph-mds@${mds_name}",
    #    stop   => "systemctl stop ceph-mds@${mds_name}",
    #    status => "systemctl status ceph-mds@${mds_name}",
    #}
}
