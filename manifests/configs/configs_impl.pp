# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::configs::impl
#
# setting configurations in ceph.conf
#
# [*configs*] A Ceph config hash.
#   Mandatory.

define kalimdor::configs::configs_impl(
  $configs,
) {
    $configs.each |$key, $val| {
 
        # set configs in ceph.conf
        if $val != '' {
            ceph_config {
                "osd/${key}":   value => $val;
            }   
        } else {
            ceph_config {
                "osd/${key}":   ensure => absent;
            }   
        }   
    }
}
