class kalimdor::configs::osd::slow_osd inherits
 kalimdor::configs::osd::base_osd {
  $slow_osd_configs = {
    osd_client_message_cap                          => 500,
    filestore_queue_max_ops                         => 100,
    filestore_queue_max_bytes                       => 104857600,
    filestore_caller_concurrency                    => 10,
    filestore_expected_throughput_bytes             => 104857600,
    filestore_expected_throughput_ops               => 200,
  }

  $osd_configs = merge($osd_configs, $slow_osd_configs) 
}
