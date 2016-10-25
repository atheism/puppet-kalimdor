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
    include kalimdor::rgw::base

    $base_rgw_options = $kalimdor::options::base::rgw_options
    $base_rgw_params  = $kalimdor::

    # set rgw options in ceph.conf
    if $rgw_enable {
        $base_rgw_options.each |$key, $val| {
            $set_val = getvar("ceph::rgw::$key")
    
            if $set_val != undef and $set_val != 'undef' {
                ceph_config {
                    "client.radosgw.${rgw_name}/${key}":   value => $set_val;
                }
            } else if $val != undef and $set_val != 'undef' {
                ceph_config {
                    "client.radosgw.${rgw_name}/${key}":   value => $val;
                }
            } else {
                ceph_config {
                    "client.radosgw.${rgw_name}/${key}":   ensure => absent;
                }
            }
        }

        if !$rgw_s3_auth_use_keystone {
            ceph_config {
                "client.radosgw.${rgw_name}/nss_db_path": ensure => absent;
                "client.radosgw.${rgw_name}/rgw_keystone_url": ensure => absent;
                "client.radosgw.${rgw_name}/rgw_keystone_admin_token": ensure => absent;
                "client.radosgw.${rgw_name}/rgw_keystone_accepted_roles": ensure => absent;
                "client.radosgw.${rgw_name}/rgw_keystone_token_cache_size": ensure => absent;
                "client.radosgw.${rgw_name}/rgw_keystone_revocation_interval": ensure => absent;
            }   
        }

        ceph::key { "client.radosgw.${rgw_name}":
            secret       => $rgw_key,
            cap_mon      => 'allow *',
            cap_osd      => 'allow *',
            inject       => true
        }
    }
    
    ceph::rgw { "radosgw.${rgw_name}":
        rgw_ensure         => 'running',
        $rgw_enable        => $rgw_enable,
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
