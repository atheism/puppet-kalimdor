class kalimdor::client(
  $cluster      = 'ceph',
){
  include ::kalimdor::params
  
  # need to inject client,admin keyrings on monitor
  # FIXME: later, admin keyrings should be classified to different clients such as rbd, rgw, cinder, nova and so on
  kalimdor::key { 'client.admin':
      secret  => $::kalimdor::params::admin_key,
      cluster => $cluster,
      keyring_path => "/etc/ceph/${cluster}.client.admin.keyring",
      cap_mon => 'allow *',
      cap_osd => 'allow *',
      cap_mds => 'allow *',
      user    => 'ceph',
      group   => 'ceph',
  }
}
