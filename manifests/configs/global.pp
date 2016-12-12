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
    'mon_host'                             => undef,
    'mon_initial_members'                  => undef,
    'osd_pool_default_pg_num'              => 1024,
    'osd_pool_default_pgp_num'             => 1024,
    'osd_pool_default_size'                => 3,
    'osd_pool_default_min_size'            => 0,
  }

  $global_configs_in_hiera = hiera('kalimdor::global', {})

  $global_final_configs = merge($global_configs, $global_configs_in_hiera)

  kalimdor::configs::configs_impl { 'global':
    configs       => $global_final_configs,
  }

  #class {'ceph':
  #    fsid                          => fix_undef($global_configs_in_hiera[fsid]),
  #    ensure                        => $ensure,
  #    keyring                       => fix_undef($global_configs_in_hiera[keyring]),
  #    authentication_type           => fix_undef($global_configs_in_hiera[authentication_type]),
  #    mon_host                      => fix_undef($global_configs_in_hiera[mon_host]),
  #    mon_initial_members           => fix_undef($global_configs_in_hiera[mon_initial_members]),
  #    osd_pool_default_pg_num       => fix_undef($global_configs_in_hiera[osd_pool_default_pg_num]),
  #    osd_pool_default_pgp_num      => fix_undef($global_configs_in_hiera[osd_pool_default_pgp_num]),
  #    osd_pool_default_size         => fix_undef($global_configs_in_hiera[osd_pool_default_size]),
  #    osd_pool_default_min_size     => fix_undef($global_configs_in_hiera[osd_pool_default_min_size]),
  #    ms_bind_ipv6                  => fix_undef($global_configs_in_hiera[ms_bind_ipv6]),
  #    cluster_network               => fix_undef($global_configs_in_hiera[cluster_network]),
  #    public_network                => fix_undef($global_configs_in_hiera[public_network]),
  #    osd_journal_size              => fix_undef($global_configs_in_hiera[osd_journal_size]),
  #}
}
