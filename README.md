# kalimdor

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with kalimdor](#setup)
    * [What kalimdor affects](#what-kalimdor-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kalimdor](#beginning-with-kalimdor)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Currently, OpenStack puppet-ceph is still not easy to use. For example, if we need
to define osds on mutiple nodes, we need to consider prepare keys, configurations,
repo seperately. Therefore, Why cannot organize and serilaze all those actions to
ease the usage complexity for the users. Kalimdor is just the project which is based
on puppet-ceph, but ease user's complexity.

## Module Description

The module simplifies the process of using puppet-ceph. Cluster' name, enable_mon,
enable_osd, enable_mds, enable_rgw, enable_client is the only parameters in the
main entry. By using enable_{roles}, we can define roles on each nodes and make that
node acts as its roles.
In addition, Directory -- Configs is used to manage the ceph's configuration. Currently,
in puppet-ceph, we need to use class conf or ceph_config to setting configuration in
ceph.conf. It is quite inconvenient to overwrite the configurations in ceph.conf and
manager the configuration for each roles. What we done in configs solves this problems.
Based on the design, there are priorities to setting configurations in the conf file.
First prorioties is the configs defined in the hiera while the second priority is the
default values defined in kalimdor. Furthermore, for osd configs, it can depend on the
type of disk used on the host.

## Setup

### What kalimdor affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**
We follow the OS compatibility of Ceph. With the release of jewel this is currently:

CentOS 7 or later

## Usage

site.pp
-------

node /server-69.3.dev3.ustack.in/{
    class {"kalimdor::cluster": }
}

hiera for one node
-------

kalimdor::global:
  fsid: 066F558C-6789-4A93-AAF1-5AF1BA01A3AD
  mon_host: 192.168.1.4
  mon_initial_members: yidong-ceph-1
  authentication_type: cephx 
  public_network: 192.168.1.0/24
  cluster_network: 192.168.1.0/24
  osd_journal_size: 15360

kalimdor::debug:
  debug_osd: '0/0'
  debug_ms:  '0/0'
  debug_optracker: '0/0'

kalimdor::osd:
  filestore_fadvise: false

kalimdor::configs::debug::enable_default_debug: true

kalimdor::enable_mon: true
kalimdor::enable_osd: true
kalimdor::enable_mds: true
kalimdor::enable_rgw: true

kalimdor::osd::osd_disk_type: sata
kalimdor::osd::osd_devices:
  "virtio-8be32092-44c9-4191-b": ":absent"
  "virtio-e98d86c5-d5de-47d1-b": ":absent"
