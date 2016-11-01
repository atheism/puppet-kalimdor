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

  # Set debug options for Ceph
  include kalimdor::configs::debug

  # We don't want to use puppet-ceph Class Ceph, but need to deal with calling dependency
  # Any ceph roles is defined on this nodes
  $enable_ceph = $enable_mon or $enable_osd or $enable_mds or $enable_rgw or $enable_client
  if $enable_ceph {
      $ceph_ensure = present
  } else {
      $ceph_ensure = absent
  }
  # Set global options for Ceph
  class {'kalimdor::configs::global':
      ensure  => $ceph_ensure,
  }

  # Define keys on this nodes
  class {'kalimdor::key':
      cluster          => $cluster,
      enable_mon       => $enable_mon,
      enable_osd       => $enable_osd,
      enable_mds       => $enable_mds,
      enable_rgw       => $enable_rgw,
      enable_client    => $enable_client, 
  }

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

  class {'kalimdor::osd':
      cluster              => $cluster,
      ensure               => $ensure_osd,
  }

  class { "kalimdor::mds":
      mds_activate         => $enable_mds,
      mds_name             => $host,
  }

  class { 'kalimdor::rgw':
      rgw_enable           => $enable_rgw,
  }

  if $enable_client{
      class {"kalimdor::client":
          cluster => $cluster,
      }
  }
}
