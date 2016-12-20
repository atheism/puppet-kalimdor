class kalimdor::configs::client {

  $client_configs = {
    rbd_cache => true,
    rbd_cache_size => 134217728,
    rbd_cache_target_dirty => 33554432,
    rbd_cache_writethrough_until_flush => true,
    rbd_cache_max_dirty => 134217728,
    rbd_cache_max_dirty_age => 30,
    rbd_default_features => 3,
    rbd_default_stripe_count => 32,
    rbd_default_stripe_unit => 131072,
    rbd_default_order => 22,
    rbd_default_format => 2,
    admin_socket => '/var/run/ceph/rbd-\$pid.asok',
  }

  $client_configs_in_hiera = hiera('kalimdor::client', {}) 

  $client_final_configs = merge($client_configs, $client_configs_in_hiera)

  kalimdor::configs::configs_impl { 'client':
    configs       => $client_final_configs,
  }
}
