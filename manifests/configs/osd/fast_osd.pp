class kalimdor::configs::osd::fast_osd inherits
 kalimdor::configs::osd::base_osd {
  $fast_osd_configs = {
    # osd op,
    osd_client_message_cap            => 20000,
    osd_client_message_size_cap       => 524288000,
    osd_op_complaint_time             => 1,
    

    # osd filestore,
    filestore_op_threads              => 6,
    filestore_queue_max_ops           => 10000,
    filestore_queue_max_bytes         => 1073741824,
    filestore_caller_concurrency      => 10,
    filestore_expected_throughput_bytes  => 209715200,
    filestore_expected_throughput_ops    => 20000,
  }

  $osd_configs = merge($osd_configs, $fast_osd_configs)
}
