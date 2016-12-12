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
    tag    => 'ceph'
  }

  Package<| tag == 'ceph' |> -> Ceph_config<| |>

  # Set debug options for Ceph
  include kalimdor::configs::debug

  # Set global options for Ceph
  include kalimdor::configs::global

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

  class {'kalimdor::osds':
      cluster              => $cluster,
      ensure               => $ensure_osd,
  }
#
#  class { "kalimdor::mds":
#      mds_activate         => $enable_mds,
#      mds_name             => $host,
#  }
#
#  class { 'kalimdor::rgw':
#      rgw_enable           => $enable_rgw,
#  }
#
#  if $enable_client{
#      class {"kalimdor::client":
#         cluster => $cluster,
#      }
#  }
}
