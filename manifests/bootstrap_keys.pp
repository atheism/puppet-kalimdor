class kalimdor::bootstrap_keys(
  $cluster,
) {

  # bootstrap-osd keyring is needed for ceph-disk to activate osd on nodes
  # maintain orders in ceph::osd
  kalimdor::key { 'client.bootstrap-osd':
      secret  => $kalimdor::params::osd_bootstrap_key,
      cluster => $cluster,
      keyring_path => "/var/lib/ceph/bootstrap-osd/${cluster}.keyring",
      cap_mon => 'allow profile bootstrap-osd',
      user    => 'ceph',
      group   => 'ceph',
      inject => true,
  } 

  kalimdor::key { 'client.bootstrap-mds':
      secret  => $kalimdor::params::mds_bootstrap_key,
      cluster => $cluster,
      keyring_path => "/var/lib/ceph/bootstrap-mds/${cluster}.keyring",
      cap_mon => 'allow profile bootstrap-mds',
      user    => 'ceph',
      group   => 'ceph',
      inject => true,
  }

  # bootstrap-rgw keyring is needed to activate rgw on nodes
  kalimdor::key { 'client.bootstrap-rgw':
      secret  => $kalimdor::params::rgw_bootstrap_key,
      cluster => $cluster,
      keyring_path => "/var/lib/ceph/bootstrap-rgw/${cluster}.keyring",
      cap_mon => 'allow profile bootstrap-rgw',
      user    => 'ceph',
      group   => 'ceph',
      inject => true,
  }


  # client.admin keyrings can only define once on each node
  # need to inject client,admin keyrings on monitor
  # FIXME: later, admin keyrings should be classified to different clients such as rbd, rgw, cinder, nova and so on
  #if $enable_client and !$enable_mon {
  #    ceph::key { 'client.admin':
  #        secret  => $kalimdor::params::admin_key,
  #        cluster => $cluster,
  #        keyring_path => "/etc/ceph/${cluster}.client.admin.keyring",
  #        cap_mon => 'allow *',
  #        cap_osd => 'allow *',
  #        cap_mds => 'allow *',
  #        user    => 'ceph',
  #        group   => 'ceph',
  #    }
  #}
}
