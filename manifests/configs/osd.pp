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
    $osd_final_configs = merge($osd_configs, $osd_configs_in_hiera)

    kalimdor::configs::configs_impl {'osd configs':
        configs       => $osd_final_configs,
    }
}
