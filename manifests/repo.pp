# Copyright (C) 2016 UnitedStack Inc.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Author: Ning Yao <yaoning@unitedstack.com>
#
# == Class: kalimdor::repo
#
# Configure yum repo for Ceph
#
# === Parameters:
#
# [*ensure*] The ensure state for package ressources.
#   Optional. Defaults to 'present'.
#
# [*release*] The name of the Ceph release to install
#   Optional. Default to 'jewel' in ceph::params.
#
# [*enable_office_repo*] Whether or not enable the repository provided by puppet-ceph
#   Optional. Defaults to false.
#
# [*repo_url*] Ceph repository url
#   Optional. Defaults to http://uds.ustack.com/repo/Bronzebeard/. 

class kalimdor::repo (
  $ensure              = present,
  $release             = $::kalimdor::params::release,
  $repo_url            = "http://uds.ustack.com/repo"
) {
    # Currently, Yum repo is the only supported repo type in Kalimdor

    if ($::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS') and (versioncmp($::operatingsystemmajrelease, '6') == 0) {
      $el = '6'
    } elsif ($::operatingsystem == 'RedHat' or $::operatingsystem == 'CentOS') and (versioncmp($::operatingsystemmajrelease, '7') == 0) {
      $el = '7'
    } else {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, \
module ${module_name} only supports osfamily RedHat, Version 6/7")
    }

    yumrepo { "uds-ceph":
      enabled    => $enabled,
      descr      => "UnitedStack Ceph CentOS ${el}",
      name       => "uds-centos-${el}",
      baseurl    => "$repo_url/${release}/el${el}",
      gpgcheck   => '0',
      gpgkey     => absent,
      mirrorlist => absent,
      priority   => '20', # prefer ceph repos over EPEL
      tag        => 'ceph',
    }
    notify{"UnitedStack Ceph Repository is Installed": message => "ceph realease: ${release}, url: $repo_url/${release}/el${el}"}
}
