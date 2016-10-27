class kalimdor::configs::mon {
  $mon_configs = {
      
  }

  $mon_configs_in_hiera = hiera('kalimdor::mon', {})
  $mon_options.each |$key, $val| {

      # the first priority is ceph class
      $set_val = $mon_configs_in_hiera[$key]

      # the second priority is kalimdor::options::mon::mon_options class
      if $set_val != '' {

          $really_val = $set_val
      } else {

          $really_val = $val
      }

      # set options in ceph.conf
      if $really_val != '' { 
          ceph_config {
              "mon/${key}":   value => $really_val;
          }   
      } else {
          ceph_config {
              "mon/${key}":   ensure => absent;
          }   
      }   
  }
}
