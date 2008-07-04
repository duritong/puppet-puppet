#
# puppet module
# modules/puppet/manifests/init.pp - manage puppet stuff
# original by luke kanies
# http://github.com/lak
# adapted by puzzel itc
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

# modules_dir { "puppet": }

class puppet {
    case $kernel {
        linux: { case $operatingsystem {
                    gentoo:  { include puppet::gentoo }
                    centos:  { include puppet::centos }
                    default: { include puppet::linux}
                 }
        }
        openbsd: { include puppet::openbsd}
    }

    $real_puppet_config = $puppet_config ? {
        '' => "/etc/puppet/puppet.conf",
        default => $puppet_config,
    }

    file { 'puppet_config':
        path => "$real_puppet_config",
        source => [ "puppet://$server/files/puppet/client/${fqdn}/puppet.conf",
                "puppet://$server/files/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/files/puppet/client/puppet.conf",
                "puppet://$server/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/puppet/client/puppet.conf" ],
        notify => Service[puppet],
        owner => root, group => 0, mode => 600;
    }
}

class puppet::linux {
    package{'puppet':
        ensure => present,
    }

    package{'facter':
        ensure => present,
    }

    service{'puppet':
        ensure => running,
        enable => true,
        hasstatus => true,
        pattern => puppetd,
        require => Package[puppet],
    }

    file{'/etc/cron.d/puppetd.cron':
        source => [ "puppet://$server/puppet/cron.d/puppetd.${operatingsystem}",
                    "puppet://$server/puppet/cron.d/puppetd" ],
        owner => root, group => 0, mode => 0644;
    }
}
class puppet::gentoo inherits puppet::linux {
    Package[puppet]{
        category => 'app-admin',
    }
    Package[facter]{
        category => 'dev-ruby',
    }
    # as we use sometimes the init script to test
    Service[puppet]{
        hasstatus => false,
    }
}
class puppet::centos inherits puppet::linux {
    file{'/etc/sysconfig/puppet':
        source => [ "puppet://$server/files/puppet/sysconfig/${fqdn}/puppet",
                    "puppet://$server/files/puppet/sysconfig/puppet",
                    "puppet://$server/puppet/sysconfig/puppet" ],
        notify => Service[puppet],
        owner => root, group => 0, mode => 0644;
    }
}
class puppet::openbsd {
    service{'puppet':
        provider => base,
        pattern => puppetd,
        ensure => running,
    }
}
