class kalimdor::rgw (
  $rgw_enable         = true,
  $rgw_ensure         = 'running',
  ) {

  include kalimdor::params

  class {'kalimdor::configs::rgw':
      rgw_name        => $rgw_name,
      rgw_enable      => $rgw_enable,
  }

  # params we don't want to modified when deployed

  $rgw_name           = "radosgw.$::hostname"
  $rgw_data           = "/var/lib/ceph/radosgw/ceph-${name}"
  $log_file           = "/var/log/ceph/radosgw.log"

  case $::kalimdor::params::release {
    'Bronzebeard': {
      $user = ceph
    }
    'Azeroth': {
      $user = root
    }
    default: {
      fail("ceph release version = $::kalimdor::params::release is not supported")
    }
  }

  unless $rgw_name =~ /^radosgw\..+/ {
    fail("Define name must be started with 'radosgw.'")
  }

  # Install ceph-radosgw packages
  if $rgw_enable {
    $package_
  }
  package { $::kalimdor::params::pkg_radosgw:
    ensure => installed,
    tag    => 'ceph',
  }

  # Data directory for radosgw
  file { '/var/lib/ceph/radosgw': # missing in redhat pkg
    ensure                  => directory,
    mode                    => '0755',
    selinux_ignore_defaults => true,
  }
  file { "/var/lib/ceph/radosgw/ceph-${rgw_name}":
    ensure                  => directory,
    owner                   => 'root',
    group                   => 'root',
    mode                    => '0750',
    selinux_ignore_defaults => true,
  }

  # Log file for radosgw (ownership)
  file { $log_file:
    ensure                  => present,
    owner                   => $user,
    mode                    => '0640',
    selinux_ignore_defaults => true,
  }

  # NOTE(aschultz): this is the radowsgw service title, it may be different
  # than the actual service name
  $rgw_service = "radosgw-${rgw_name}"

  # service definition
  if $::kalimdor::params::release == 'Azeroth' {
    Service {
      name     => "radosgw-${rgw_name}",
      start    => "start radosgw id=${rgw_name}",
      stop     => "stop radosgw id=${rgw_name}",
      status   => "status radosgw id=${rgw_name}",
      provider => "service",
    }
  } elsif $::kalimdor::params::release == 'Bronzebeard' {
    Service {
      name   => "ceph-radosgw@${rgw_name}",
      provider => "systemd",
      enable => $rgw_enable,
    }
  } else {
    fail("ceph release version = $::kalimdor::params::release is not supported")
  } 

  service { $rgw_service:
    ensure => $rgw_ensure,
    tag    => ['ceph-radosgw']
  }

  Ceph_config<||> ~> Service<| tag == 'ceph-radosgw' |>
  Package<| tag == 'ceph' |> -> File['/var/lib/ceph/radosgw']
  Package<| tag == 'ceph' |> -> File[$log_file]
  File['/var/lib/ceph/radosgw']
  -> File[$rgw_data]
  -> Service<| tag == 'ceph-radosgw' |>
  File[$log_file] -> Service<| tag == 'ceph-radosgw' |>

}
