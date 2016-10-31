class kalimdor::configs::mon {
  $mon_configs = {
      
  }

  $mon_configs_in_hiera = hiera('kalimdor::mon', {})

  $mon_final_configs = merge($mon_configs, $mon_configs_in_hiera)

  kalimdor::configs::configs_impl { 'mon':
    configs       => $mon_final_configs,
  }
}
