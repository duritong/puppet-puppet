#
# puppet module
# modules/puppet/manifests/init.pp - manage puppet stuff
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

# modules_dir { "puppet": }

class puppet {
    case $kernel {
        linux: { 
            case $operatingsystem {
                gentoo:  { include puppet::gentoo }
                centos:  { include puppet::centos }
                debian:  { include puppet::debian }
                default: { include puppet::linux}
            }
        }
        openbsd: { include puppet::openbsd }
        default: { include puppet::base }
    }

}

class puppet::base {
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
    service{'puppet':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
        pattern => puppetd,
    }

}

class puppet::linux inherits puppet::base {
    package{ [ 'puppet', 'facter' ]:
        ensure => present,
    }

    # package bc needed for cron
    include bc
    Service['puppet']{
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
class puppet::debian inherits puppet::linux {
    file{'/etc/default/puppet':
        source => [ "puppet://$server/files/puppet/client/debian/${fqdn}/puppet",
                    "puppet://$server/files/puppet/client/debian/${domain}/puppet",
                    "puppet://$server/files/puppet/client/debian/puppet",
                    "puppet://$server/puppet/client/debian/puppet" ],
        notify => Service[puppet],
        owner => root, group => 0, mode => 0644;
    }    # there is really no status cmd for it
    Service[puppet]{
        hasstatus => false,
    }
    File['/etc/cron.d/puppetd.cron']{
        path => '/etc/cron.d/puppetd',
    }
}

class puppet::centos inherits puppet::linux {
    file{'/etc/sysconfig/puppet':
        source => [ "puppet://$server/files/puppet/sysconfig/${fqdn}/puppet",
                    "puppet://$server/files/puppet/sysconfig/${domain}/puppet",
                    "puppet://$server/files/puppet/sysconfig/puppet",
                    "puppet://$server/puppet/sysconfig/puppet" ],
        notify => Service[puppet],
        owner => root, group => 0, mode => 0644;
    }
}
class puppet::openbsd inherits puppet::base {
    Service['puppet']{
        restart => '/bin/kill -HUP `/bin/cat /var/run/puppet/puppetd.pid`',
        stop => '/bin/kill `/bin/cat /var/run/puppet/puppetd.pid`',
        start => '/usr/local/bin/puppetd',
        hasstatus => false,
        hasrestart => false,
    }
    openbsd::add_to_rc_local{'puppetd':
        binary => '/usr/local/bin/puppetd',
    }
    cron { 'puppetd_check':
        command => '/bin/ps ax | /bin/grep -v grep | /bin/grep -q puppetd || (sleep `echo $RANDOM/2000*60 | bc` && /usr/local/bin/puppetd)',
        user => root,
        minute => 0,
    }
    cron { 'puppetd_restart':
        command => 'sleep `echo $RANDOM/2000*60 | bc` && /bin/kill `/bin/cat /var/run/puppet/puppetd.pid`; /usr/local/bin/puppetd',
        minute => 0,
        hour => 22,
        monthday => '*/2',
    } 
}
