Usage
=====

site.pp
-------

	node /server-69.3.dev3.ustack.in/{
   		class {"kalimdor::cluster": }
	}


hieradata
---------


	kalimdor::cluster::public_network: 10.0.19.0/24
	kalimdor::cluster::cluster_network: 10.0.19.0/24

	kalimdor::cluster::mon_hosts: 10.0.19.69
	kalimdor::cluster::mon_initial_members: server-69
	kalimdor::cluster::debug_enable: true

	kalimdor::cluster::enable_mon: true

	kalimdor::cluster::enable_osd: true
	kalimdor::osd::disk_type: "ssd"
	kalimdor::osd::osd_device_dict:
	  "wwn-0x55cd2e404bcdf711": ""
	  "wwn-0x55cd2e404bcdee9a": ""
	  "wwn-0x55cd2e404bcded26": ""
