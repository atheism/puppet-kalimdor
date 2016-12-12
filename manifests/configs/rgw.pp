class kalimdor::configs::rgw(
  $rgw_name   = undef,
  $rgw_enable = true,
){

  $rgw_configs = {
      # rgw performance options
      rgw_override_bucket_index_max_shards  => 0,
      rgw_cache_enabled                     => true,
      rgw_cache_lru_size                    => 10000,
      rgw_num_rados_handles                 => 1,
      rgw_swift_token_expiration            => 86400,
      rgw_thread_pool_size                  => 8,

      # keystone auth options
      rgw_keystone_url                     => "http://keyston.com:35357/",
      rgw_keystone_admin_token             => "admin",
      rgw_keystone_admin_user              => undef,
      rgw_keystone_admin_password          => undef,
      rgw_keystone_admin_tenant            => undef,
      rgw_keystone_admin_project           => undef,
      rgw_keystone_admin_domain            => undef,
      rgw_keystone_api_version             => undef,
      rgw_keystone_accepted_roles          => "_member_, admin",
      rgw_keystone_token_cache_size        => 10000,
      rgw_keystone_revocation_interval     => 900,
      rgw_keystone_verify_ssl              => undef,
      rgw_keystone_implicit_tenants        => undef,
      rgw_s3_auth_use_rados                => true,
      rgw_s3_auth_use_keystone             => false,

      # ldap auth options
      rgw_ldap_uri                         => undef,
      rgw_ldap_binddn                      => undef,
      rgw_ldap_searchdn                    => undef,
      rgw_ldap_dnattr                      => undef,
      rgw_ldap_secret                      => undef,
      rgw_s3_auth_use_ldap                 => false,
  }

  $rgw_configs_in_hiera = hiera('kalimdor::rgw', {})
  $rgw_final_configs = merge($rgw_configs, $rgw_configs_in_hiera)
 
  kalimdor::configs::configs_impl {'client.radosgw.${rgw_name}':
      configs       => $rgw_final_configs,
      enable        => $rgw_enable,
  }
}
