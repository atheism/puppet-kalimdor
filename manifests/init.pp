# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Li Tianqing <tianqing@unitedstack.com>
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor
#
# init takes care of defining roles in ceph cluster for each node
# it also takes care of the global configuration values
#
# [*cluster*] The ceph cluster
#   Optional. Same default as ceph.
#
# [*enable_mon*] Whether or not enable Monitor on the node
#   Optional. Default to false
#
# [*enable_osd*] Whether or not enable OSD on the node
#   Optional. Default to false
#
# [*enable_mds*] Whether or not enable MDS on the node
#   Optional. Default to false
#
# [*enable_rgw*] Whether or not enable RGW on the node
#   Optional. Default to false
#
# [*enable_client*] Whether or not enable Client on the node
#   Optional. Default to false
#
# [*enable_default_debug*] Whether or not enable default debug level setting by Ceph
#   Optional. Default to true
#   If false, all modules' debug level sets to '0/0'
#   Althrough disable all debug information can improve performance
#   it may lead to hard troubleshooting when dealing with BUGs

class kalimdor(
  $cluster                      = 'ceph',
  $enable_mon                   = false,
  $enable_osd                   = false,
  $enable_mds                   = false,
  $enable_rgw                   = false,
  $enable_client                = false,
){

  include ::stdlib
  
  # Ceph repository configurations
  include kalimdor::params
  include kalimdor::repo

  # Install package Ceph
  package { $::kalimdor::params::packages:
    ensure => present,
    tag    => 'ceph',
  }

  Package<| tag == 'ceph' |> -> Ceph_config<| |>

  # Set debug options for Ceph
  include kalimdor::configs::debug

  # Set global options for Ceph
  include kalimdor::configs::global

  # Set client options for Ceph
  include kalimdor::configs::client

  # Whether enable Monitor on this nodes?
  if $enable_mon {
      $mon_ensure = present
  } else {
      $mon_ensure = absent
  }

  class {'kalimdor::mon':
      cluster                  => $cluster,
      ensure                   => $mon_ensure,
      authentication_type      => $authentication_type,
  }

  # Whether enable OSD on this nodes?
  if $enable_osd {
      $osd_ensure = present
  } else {
      $osd_ensure = absent
  }
  class {'kalimdor::osds':
      cluster              => $cluster,
      ensure               => $osd_ensure,
  }

  if $enable_mds {
      $mds_ensure = present
  } else {
      $mds_ensure = absent
  }
  class { "kalimdor::mds":
      cluster        => $cluster,
      ensure         => $mds_ensure,
  }

  if $enable_rgw {
      $rgw_ensure = present
  } else {
      $rgw_ensure = absent
  }
  class { 'kalimdor::rgw':
      cluster        => $cluster,
      ensure         => $rgw_ensure,
  }

  $need_enable_client= !$enable_mon and ($enable_osd or $enable_mds or $enable_rgw or $enable_client)
  if $need_enable_client {
      class {"kalimdor::client":
         cluster => $cluster,
      }
  }
}
