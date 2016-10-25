class kalimdor::options::osd(
  $host_osd_type      = 'fast',
  ){

    $osd_options = $kalimdor::options::base_osd::osd_options
    case $host_osd_type {
        fast: {
            include kalimdor::options::fast_osd
            $tune_osd_options = $kalimdor::options::fast_osd::osd_options
        }
        slow: {
            include kalimdor::options::slow_osd
            $tune_osd_options = $kalimdor::options::slow_osd::osd_options
        }
        default: {
            include kalimdor::options::base_osd
            $tune_osd_options = $kalimdor::options::base_osd::osd_options
        }
    }

    $osd_options.each |$key, $val| {
 
        # the first priority is ceph class
        $set_val = getvar("ceph::osd::$key")

        # the second priority is ceph::osd_perf::{disk_type} class
        $tune_val = $tune_osd_options[$key]


        # the third priority is ceph::osd::base class
        if $set_val {

            $really_val = $set_val
        } elsif $tune_val {

            $really_val = $tune_val
        } else {
        
            $really_val = $val
        }

        notify{"$key: ": message => "$really_val"}
        # set options in ceph.conf
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
