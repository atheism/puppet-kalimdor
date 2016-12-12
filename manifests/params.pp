class kalimdor::params(
  $release                                  = 'Bronzebeard',

  $admin_key                                = 'AQCTg71RsNIHORAAW+O6FCMZWBjmVfMIPk3MhQ==',
  $mon_key                                  = 'AQDesGZSsC7KJBAAw+W/Z4eGSQGAIbxWjxjvfw==',
  $osd_bootstrap_key                        = 'AQAj2zpXuKuSDhAA3lJI2A3IAd72Ze9Q4M58jg==',
  $mds_bootstrap_key                        = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',
  $rgw_bootstrap_key                        = 'AQCTg71RsNIHORAAW+O6FCMZWBjmVfMIPk3MhQ==',

  $enable_default_debug                     = true,
  $exec_timeout                             = 600,
){
  $packages                                 = 'ceph'
  $pkg_radosgw                              = 'ceph-radosgw'
}
