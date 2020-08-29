#
# puppet module
# manifests/init.pp - manage puppet stuff
# original by luke kanies
# http://github.com/lak
# adapted by puzzle itc
# merged with immerda project group's
# solution
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Haerry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.
#
# Manage the puppet client
class puppet(
  $config                     = '/etc/puppet/puppet.conf',
  $config_content             = false,
  $http_compression           = false,
  $cleanup_clientbucket       = false,
  $ensure_version             = 'installed',
  $ensure_facter_version      = 'installed',
  $firewall_puppetmaster      = false,
  $firewall_puppetmaster_port = 8140,
){
  case $::kernel {
    linux: {
      case $::operatingsystem {
        gentoo: { include puppet::gentoo }
        centos: { include puppet::centos }
        debian,ubuntu: { include puppet::debian }
        default: { include puppet::linux}
      }
    }
    openbsd: { include puppet::openbsd }
    default: { include puppet::base }
  }

  if $shorewall_puppetmaster {
    class{'firewall::rules::out::puppet':
      puppetserver      => $firewall_puppetmaster,
      puppetserver_port => $firewall_puppetmaster_port,
    }
  }
}
