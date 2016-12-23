class kalimdor::mds (
  $ensure                = present,
  $cluster               = 'ceph',
  $host                  = $::hostname,
  $mds_key               = $::kalimdor::params::mds_key,
) {
    $mds_dir = "${cluster}-${host}"
    $mds_name = "${host}"
    $mds_data = "/var/lib/ceph/mds/${mds_dir}"
    $keyring = "/var/lib/ceph/mds/${mds_dir}/keyring"

    if $ensure == 'present' {
      file { $mds_data:
        ensure => 'directory',
        owner  => 'ceph',
        group  => 'ceph'
      } -> Kalimdor::Key["mds.${mds_name}"]
      Kalimdor::Key["client.admin"] -> Kalimdor::Key["mds.${mds_name}"]
      kalimdor::key { "mds.${mds_name}":
          secret       => $mds_key,
          cluster      => $cluster,
          cap_mon      => 'allow profile mds',
          cap_osd      => 'allow rwx',
          cap_mds      => 'allow *',
          user         => 'ceph',
          group        => 'ceph',
          keyring_path => $keyring,
          inject       => true
      }

      Service {
        name   => "ceph-mds@$mds_name",
        enable => true,
      }

      ceph_config {
        'mds/host':     value => $host;
        'mds/mds_data': value => $mds_data;
        'mds/keyring':  value => $keyring;
      }

      service { $mds_name:
        ensure => true,
        tag    => ['ceph-mds']
      }
    } elsif $ensure == absent {
      Service {
        name   => "ceph-mds@$mds_name",
        enable => false,
      }
      
      service { $mds_name:
        ensure => false,
        tag    => ['ceph-mds']
      }
      exec { "remove-mds-${mds_name}":
        command   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ceph auth del mds.${mds_name}
rm -fr ${mds_data}
",
        logoutput => true,
        timeout   => $exec_timeout,
      } 
      ceph_config {
        'mds/host':     ensure => absent;
        'mds/mds_data': ensure => absent;
        'mds/keyring':  ensure => absent;
      } -> Ceph::Mon<| ensure == absent |>
    } else {
      fail('Ensure on MDS must be either present or absent')
    }
}
