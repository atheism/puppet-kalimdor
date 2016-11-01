class kalimdor::rgw (
  $rgw_enable                   = true,
  $rgw_name                     = $::hostname,
  $user                         = root,
  $rgw_dns_name                 = $::fqdn,
  $frontend_type                = 'civetweb',
  $rgw_frontends                = "civetweb port=7480",
  $rgw_enable_apis              = "s3, admin",
  $rgw_s3_auth_use_keystone     = false,
  $rgw_key                      = ::kalimdor::params::rgw_bootstrap_key,
  ) {

    include kalimdor::params

    class {'kalimdor::configs::rgw':
        rgw_name        => $rgw_name,
    }

    ceph::rgw { "radosgw.${rgw_name}":
        rgw_ensure         => 'running',
        rgw_enable        => $rgw_enable,
        rgw_data           => $kalimdor::rgw::base::rgw_data,
        user               => $user,
        keyring_path       => $kalimdor::rgw::base::keyring_path,
        log_file           => $kalimdor::rgw::base::log_file,
        rgw_dns_name       => $kalimdor::rgw::base::rgw_dns_name,
        rgw_socket_path    => $kalimdor::rgw::base::rgw_socket_path,
        rgw_print_continue => $kalimdor::rgw::base::rgw_print_continue,
        rgw_port           => $kalimdor::rgw::base::rgw_port,
        frontend_type      => $kalimdor::rgw::base::frontend_type,
        rgw_frontends      => $kalimdor::rgw::base::rgw_frontends,
    }

}
