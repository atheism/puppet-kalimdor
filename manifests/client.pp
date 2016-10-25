
class kalimdor::client(
  $cluster      = 'ceph',
){
    include ::kalimdor::params

    ceph::key { 'client.admin':
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
