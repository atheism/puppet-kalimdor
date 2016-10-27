# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::params::global
#
# setting global parameters for each node

class kalimdor::options::global { 
  $global_params = {
    'fsid'                                 => undef,
    'cluster_network'                      => undef,
    'public_network'                       => undef,
    'require_signatures'                   => false,
    'cluster_require_signatures'           => false,
    'service_require_signatures'           => false,
    'sign_messages'                        => true,
  }

  $global_params_in_hiera = hiera('kalimdor::global') |$key_in_hiera| {"Key '${key_in_hiera}' not found"}
  $global_params.each |$key, $val| {
 
      $set_val = $global_params_in_hiera[$key]

      if $set_val {

          $really_val = $set_val
      } else {

          $really_val = $val
      }

      # set options in ceph.conf
      if $really_val != '' { # undef automatically becomes an empty string, fix me if needed
          ceph_config {
              "global/${key}":   value => $really_val;
          }
      } else {
          fail("global options ${key} must be set explicitly. undef value is not allowed")
      }
  }
}
