# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Li Tianqing <tianqing@unitedstack.com>
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::configs::debug
#
# setting debug configurations for each node
#
# [*enable_default_debug*] Whether or not enable default debug level setting by Ceph
#   Optional. Default to true
#   If false, all modules' debug level sets to '0/0'
#   Althrough disable all debug information can improve performance
#   it may lead to hard troubleshooting when dealing with BUGs

class kalimdor::configs::debug (
  $enable_default_debug     = true,
) {

  $debug_configs = {
      debug_none            => undef, # "0\/5"
      debug_lockdep         => undef, # "0\/1"
      debug_context         => undef, # "0\/1"
      debug_crush           => undef, # "1\/1"
      debug_mds             => undef, # "1\/5"
      debug_mds_balancer    => undef, # "1\/5"
      debug_mds_locker      => undef, # "1\/5"
      debug_mds_log         => undef, # "1\/5"
      debug_mds_log_expire  => undef, # "1\/5"
      debug_mds_migrator    => undef, # "1\/5"
      debug_buffer          => undef, # "0\/1"
      debug_timer           => undef, # "0\/1"
      debug_filer           => undef, # "0\/1"
      debug_striper         => undef, # "0\/1"
      debug_objecter        => undef, # "0\/1"
      debug_rados           => undef, # "0\/5"
      debug_rbd             => undef, # "0\/5"
      debug_rbd_mirror      => undef, # "0\/5"
      debug_rbd_replay      => undef, # "0\/5"
      debug_journaler       => undef, # "0\/5"
      debug_objectcacher    => undef, # "0\/5"
      debug_client          => undef, # "0\/5"
      debug_osd             => '0/0', # "0\/5"
      debug_optracker       => '0/0', # "0\/5"
      debug_objclass        => undef, # "0\/5"
      debug_filestore       => undef, # "1\/3"
      debug_journal         => undef, # "1\/3"
      debug_ms              => '0/0', # "0\/5"
      debug_mon             => undef, # "1\/5"
      debug_monc            => undef, # "0\/10"
      debug_paxos           => undef, # "1\/5"
      debug_tp              => undef, # "0\/5"
      debug_auth            => undef, # "1\/5"
      debug_crypto          => undef, # "1\/5"
      debug_finisher        => undef, # "1\/1"
      debug_heartbeatmap    => undef, # "1\/5"
      debug_perfcounter     => undef, # "1\/5"
      debug_rgw             => undef, # "1\/5"
      debug_civetweb        => undef, # "1\/10"
      debug_javaclient      => undef, # "1\/5"
      debug_asok            => undef, # "1\/5"
      debug_throttle        => undef, # "1\/1"
      debug_refs            => undef, # "0\/0"
      debug_xio             => undef, # "1\/5"
      debug_compressor      => undef, # "1\/5"
      debug_bluestore       => undef, # "1\/5"
      debug_bluefs          => undef, # "1\/5"
      debug_bdev            => undef, # "1\/3"
      debug_kstore          => undef, # "1\/5"
      debug_rocksdb         => undef, # "4\/5"
      debug_leveldb         => undef, # "4\/5"
      debug_kinetic         => undef, # "1\/5"
      debug_fuse            => undef, # "1\/5"
  }

  $default_val = $enable_default_debug ? {
        false   => '0/0',
        default => undef,
  }

  $debug_configs_in_hiera = hiera('kalimdor::debug', {})

  $debug_configs.each |$key, $val| {
   
    $set_val = $debug_configs_in_hiera[$key]
 
    if $set_val {
        $really_val = $set_val
    } elsif $val {
        $really_val = $val
    } else {
        $really_val = $default_val
    }

    if $really_val { 
        ceph_config {
            "global/${key}":   value => $really_val;
        }
    } else {
        ceph_config {
            "global/${key}":   ensure => absent;
        }
    }
  }
}

