# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::params::global
#
# setting global configurations for each node

class kalimdor::configs::global { 
  $global_configs = {
    'fsid'                                 => undef,
    'cluster_network'                      => undef,
    'public_network'                       => undef,
    'require_signatures'                   => false,
    'cluster_require_signatures'           => false,
    'service_require_signatures'           => false,
    'sign_messages'                        => true,
  }

  $global_configs_in_hiera = hiera('kalimdor::global', {})
  $global_configs.each |$key, $val| {
 
      $set_val = $global_configs_in_hiera[$key]

      # undef automatically becomes an empty string, fix me if needed
      # value 'false' should be considered as a valid value, undef will convert to false if it is a bool type
      if $set_val != '' {

          $really_val = $set_val
      } else {

          $really_val = $val
      }

      # set options in ceph.conf
      if $really_val != '' {
          ceph_config {
              "global/${key}":   value => $really_val;
          }
      } else {
          # global configs must be explicitly set
          fail("global configs ${key} must be set explicitly. undef value is not allowed")
      }
  }
}
