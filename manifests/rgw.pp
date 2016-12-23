class kalimdor::rgw (
  $cluster            = 'ceph',
  $ensure             = present,
  $rgw_key            = $::kalimdor::params::rgw_key,
  $exec_timeout       = $::kalimdor::params::exec_timeout,
  ) {

  include kalimdor::params

  # params we don't want to modified when deployed
  $rgw_name           = "radosgw.$::hostname"
  $rgw_data           = "/var/lib/ceph/radosgw/ceph-${rgw_name}"
  $log_file           = "/var/log/ceph/radosgw.log"
  $keyring = "$rgw_data/keyring"

  class {'kalimdor::configs::rgw':
      rgw_name        => $rgw_name,
      rgw_ensure      => $ensure,
  }

  if $ensure == 'present' {
  
    unless $rgw_name =~ /^radosgw\..+/ {
      fail("Define name must be started with 'radosgw.'")
    }
  
    # Install ceph-radosgw packages
    package { $::kalimdor::params::pkg_radosgw:
      ensure => $ensure,
      tag    => 'ceph',
    }
  
    # Data directory for radosgw
    file { '/var/lib/ceph/radosgw': # missing in redhat pkg
      ensure                  => directory,
      mode                    => '0755',
      selinux_ignore_defaults => true,
    }
    file { $rgw_data:
      ensure                  => directory,
      owner                   => 'root',
      group                   => 'root',
      mode                    => '0750',
      selinux_ignore_defaults => true,
    }
  
    # Log file for radosgw (ownership)
    file { $log_file:
      ensure                  => present,
      owner                   => 'ceph',
      mode                    => '0640',
      selinux_ignore_defaults => true,
    }

    File["/var/lib/ceph/radosgw"] -> Kalimdor::Key["client.${rgw_name}"]
    Kalimdor::Key["client.admin"] -> Kalimdor::Key["client.${rgw_name}"]
    kalimdor::key { "client.${rgw_name}":
      secret       => $rgw_key,
      cluster      => $cluster,
      cap_mon      => 'allow rw',
      cap_osd      => 'allow rwx',
      user         => 'ceph',
      group        => 'ceph',
      keyring_path => $keyring,
      inject       => true
    }
  
    # NOTE(aschultz): this is the radowsgw service title, it may be different
    # than the actual service name
    $rgw_service = "radosgw-${rgw_name}"
  
    # service definition
    Service {
      name   => "ceph-radosgw@${rgw_name}",
      provider => "systemd",
      enable => true,
    }
  
    service { $rgw_service:
      ensure => 'running',
      tag    => ['ceph-radosgw']
    }

    Ceph_config<||> ~> Service<| tag == 'ceph-radosgw' |>
    Package<| tag == 'ceph' |> -> File['/var/lib/ceph/radosgw']
    Package<| tag == 'ceph' |> -> File[$log_file]
    File['/var/lib/ceph/radosgw']
    -> File[$rgw_data]
    -> Service<| tag == 'ceph-radosgw' |>
    File[$log_file] -> Service<| tag == 'ceph-radosgw' |>
  } elsif $ensure == absent {
    $rgw_service = "radosgw-${rgw_name}"
    # service definition
    Service {
      name   => "ceph-radosgw@${rgw_name}",
      provider => "systemd",
      enable => false,
    }

    service { $rgw_service:
      ensure => 'stopped',
      tag    => ['ceph-radosgw']
    }->
    exec { "remove-rgw-${rgw_name}":
      command   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ceph auth del client.${rgw_name}
rm -fr ${rgw_data}
",
      logoutput => true,
      timeout   => $exec_timeout,
    }
  } else {
    fail('Ensure on RGW must be either present or absent')
  }
}
