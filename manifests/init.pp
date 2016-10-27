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
  $authentication_type          = 'cephx',
  $enable_mon                   = 'false',
  $enable_osd                   = 'false',
  $enable_mds                   = 'false',
  $enable_rgw                   = 'false',
  $enable_client                = 'false',
){

  include ::stdlib
  
  # Ceph repository configurations
  include kalimdor::params
  include kalimdor::repo

  # Set global options for Ceph
  include kalimdor::configs::global
 
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

  class {'ceph':
      fsid                     => $kalimdor::configs::global::fsid,
      ensure                   => $ceph_ensure,
      authentication_type      => $authentication_type,
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
      enable_dangerous_operation => $enable_dangerous_operation,
  }

  if $ensure_mds == present {
    $mds_activate = true
  } else {
    $mds_activate = false
  }
  class { "kalimdor::mds":
      mds_activate         => $mds_activate,
      mds_name             => $host,
  }

  if $ensure_rgw == present  {
     class { 'kalimdor::rgw':
          rgw_enable           => true,
     }
  }

  if $ensure_client == present {
      class {"kalimdor::client":
          cluster => $cluster,
      }   
  }
}
