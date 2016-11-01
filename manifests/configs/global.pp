# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::params::global
#
# setting global configurations for each node

class kalimdor::configs::global(
  $ensure         = present,
){ 
  $global_configs = {
    'fsid'                                 => undef,
    'authentication_type'                  => undef,
    'cluster_network'                      => undef,
    'public_network'                       => undef,
    'osd_pool_default_pg_num'              => 1024,
    'osd_pool_default_pgp_num'             => 1024,
    'osd_pool_default_size'                => 3,
    'osd_pool_default_min_size'            => 0,
  }

  $global_configs_in_hiera = merge($global_configs, hiera('kalimdor::global', {}))
  
  class {'ceph':
      fsid                          => $global_configs_in_hiera[fsid],
      ensure                        => $ensure,
      keyring                       => $global_configs_in_hiera[keyring],
      authentication_type           => $global_configs_in_hiera[authentication_type],
      osd_pool_default_pg_num       => $global_configs_in_hiera[osd_pool_default_pg_num],
      osd_pool_default_pgp_num      => $global_configs_in_hiera[osd_pool_default_pgp_num],
      osd_pool_default_size         => $global_configs_in_hiera[osd_pool_default_size],
      osd_pool_default_min_size     => $global_configs_in_hiera[osd_pool_default_min_size],
      ms_bind_ipv6                  => $global_configs_in_hiera[ms_bind_ipv6],
      cluster_network               => $global_configs_in_hiera[cluster_network],
      public_network                => $global_configs_in_hiera[public_network],
  }

}
