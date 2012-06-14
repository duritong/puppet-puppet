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
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.
#

class puppet(
  $config = '/etc/puppet/puppet.conf',
  $http_compression = false,
  $cleanup_clientbucket = false,
  $ensure_version = 'installed',
  $ensure_facter_version = 'installed',
  $manage_shorewall = false,
  $puppetmaster = "puppet.${::domain}",
  $puppetserver_port = 8140,
  $puppetserver_signport = 8141
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

  if $manage_shorewall {
    class{'shorewall::rules::out::puppet':
      puppetserver          => $puppetserver,
      puppetserver_port     => $puppetserver_port,
      puppetserver_signport => $puppetserver_signport,
    }
  }
}
