class kalimdor::options::slow_osd inherits
 kalimdor::options::base_osd {
  $slow_osd_options = {
    filestore_queue_max_ops                         => 1000,
    filestore_queue_max_bytes                       => 104857600,
    filestore_caller_concurrency                    => 10,
    filestore_expected_throughput_bytes             => 104857600,
    filestore_expected_throughput_ops               => 200,
  }
}
