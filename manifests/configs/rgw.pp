class kalimdor::configs::rgw(
  $rgw_name   = undef,
  $rgw_ensure = present,
){

  $rgw_configs = {
      # rgw performance options
      rgw_override_bucket_index_max_shards  => 0,
      rgw_cache_enabled                     => true,
      rgw_cache_lru_size                    => 100000,
      rgw_num_rados_handles                 => 20,
      rgw_swift_token_expiration            => 86400,
      rgw_thread_pool_size                  => 256,
      rgw_bucket_index_max_aio              => 8,

      #object
      rgw_obj_stripe_size                   => 4194304,
      rgw_exit_timeout_secs                 => 120,
      rgw_get_obj_window_size               => 16777216,
      rgw_get_obj_max_req_size              => 4194304,

      #multipart
      rgw_multipart_min_part_size           => 5242880,
      rgw_olh_pending_timeout_sec           => 3600,

      #gc
      rgw_enable_gc_threads                 => true,
      rgw_gc_max_objs                       => 32,
      rgw_gc_obj_min_wait                   => 7200,
      rgw_gc_processor_max_time             => 3600,
      rgw_gc_processor_period               => 3600,

      #quota, usage and log
      rgw_enable_quota_threads              => true,
      rgw_user_max_buckets                  => 1000,
      rgw_bucket_quota_ttl                  => 600,
      rgw_bucket_quota_soft_threshold       => 0.95,
      rgw_bucket_quota_cache_size           => 10000,
      rgw_user_quota_bucket_sync_interval   => 180,
      rgw_user_quota_sync_interval          => 86400,
      rgw_user_quota_sync_idle_users        => false,
      rgw_user_quota_sync_wait_time         => 86400,
      rgw_usage_max_shards                  => 32,
      rgw_usage_max_user_shards             => 1,
      rgw_enable_usage_log                  => true,
      rgw_enable_ops_log                    => false,
      rgw_ops_log_rados                     => true,
      rgw_ops_log_data_backlog              => 5242880,
      rgw_usage_log_flush_threshold         => 1024,
      rgw_usage_log_tick_interval           => 30,
      rgw_md_log_max_shards                 => 6
      rgw_data_log_window                   => 30
      rgw_data_log_changes_size             => 1000
      rgw_data_log_num_shards               => 128

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

  if $rgw_ensure == 'present' {
    $rgw_enable = true
  } elsif $rgw_ensure == 'absent'{
    $rgw_enable = false
  } else {
    fail('Ensure on RGW must be either present or absent')    
  }
  kalimdor::configs::configs_impl {"client.radosgw.${rgw_name}":
      configs       => $rgw_final_configs,
      enable        => $rgw_enable,
  }
}
