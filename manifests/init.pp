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
  $config                           = '/etc/puppet/puppet.conf',
  $config_content                   = false,
  $http_compression                 = false,
  $cleanup_clientbucket             = false,
  $ensure_version                   = 'installed',
  $ensure_facter_version            = 'installed',
  $shorewall_puppetmaster           = false,
  $shorewall_puppetmaster_port      = 8140,
  $shorewall_puppetmaster_signport  = 8141
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
    class{'shorewall::rules::out::puppet':
      puppetserver          => $shorewall_puppetmaster,
      puppetserver_port     => $shorewall_puppetmaster_port,
      puppetserver_signport => $shorewall_puppetmaster_signport,
    }
  }
}
