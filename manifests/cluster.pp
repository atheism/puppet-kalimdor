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

class kalimdor::cluster(
  $fsid,
  $cluster                      = 'ceph',
  $authentication_type          = 'cephx',

  $public_network               = undef,
  $cluster_network              = undef,

  $enable_mon                   = false,
  $enable_osd                   = false,
  $enable_mds                   = false,
  $enable_rgw                   = false,
  $enable_client                = false,

  $osd_disk_type                = undef,
  $enable_default_debug         = ::kalimdor::params::enable_default_debug,
  $enable_dangerous_operation   = ::kalimdor::params::enable_dangerous_operation,
  ){

  include ::kalimdor::params
  notify{"my params: $enable_dangerous_operation": message => ""}

  $enable_ceph = $enable_mon or $enable_osd or $enable_mds or $enable_rgw or $enable_client
  
  if $enable_ceph {
      $ceph_ensure = present
  } else {
      $ceph_ensure = absent
  }

  class { 'ceph':
      fsid                   => $fsid,
      ensure                 => $ceph_ensure,
      authentication_type    => $authentication_type,
      public_network         => $public_network,
      cluster_network        => $cluster_network,
  }

  if $enable_mon {
      class {'kalimdor::mon':
          cluster                  => $cluster,
          ensure                   => present,
          authentication_type      => $authentication_type,
      }
  } else {
      if $enable_dangerous_operation {
          class {'kalimdor::mon':
              cluster                  => $cluster,
              ensure                   => absent,
              authentication_type      => $authentication_type, 
          }
      }
  }

  if $enable_client{
      class {"kalimdor::client":
          cluster => $cluster,
      }
  }

  if $enable_osd {
      class {'kalimdor::osd':
          cluster              => $cluster,
          ensure               => present,
          enable_dangerous_operation => $enable_dangerous_operation,
      }
  }

  if $enable_rgw  {
     class { 'kalimdor::rgw':
          rgw_enable           => true,
     }
  }

  if $enable_mds {
      class { "kalimdor::mds":
          mds_activate         => $enable_mds,
          mds_name             => $host,
      }
  }

  class { "kalimdor::options::debug":
      enable_default_debug     => $enable_default_debug,
  }
}
