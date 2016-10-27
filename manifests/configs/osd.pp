# Copyright 2016 (C) UnitedStack Inc.
#
# Author: Yao Ning <yaoning@unitedstack.com>
#
# == Class: kalimdor::configs::global
#
# setting global parameters for each node

class kalimdor::configs::osd(
  $host_osd_type      = 'fast',
  ){

    $osd_configs_in_hiera = hiera('kalimdor::osd', {})
    case $host_osd_type {
        fast: {
            include kalimdor::configs::osd::fast_osd
        }
        slow: {
            include kalimdor::configs::osd::slow_osd
        }
        default: {
            include kalimdor::configs::osd::base_osd
        }
    }
    $osd_configs.each |$key, $val| {
 
        $set_val = $osd_configs_in_hiera[$key]
        $tune_val = $osd_configs_in_tune[$key]

        if $set_val {

            $really_val = $set_val
        } elsif $tune_val {

            $really_val = $tune_val
        } else {
        
            $really_val = $val
        }

        # set configs in ceph.conf
        if $really_val {
            ceph_config {
                "osd/${key}":   value => $really_val;
            }   
        } else {
            ceph_config {
                "osd/${key}":   ensure => absent;
            }   
        }
    }
}
