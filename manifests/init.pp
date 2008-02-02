# modules/puppet/manifests/init.pp - manage puppet stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "puppet": }

class puppet {
    case $kernel {
        linux: { include puppet::linux}
        openbsd: { include puppet::openbsd}
    }
}

class puppet::linux {
    package{'puppet':
        name => 'puppet',
        category => $operatingsystem ? {
            gentoo => 'app-admin',
            default => '',
        },
        ensure => present,
    }

    package{'facter':
        name => 'facter',
        category => $operatingsystem ? {
            gentoo => 'dev-ruby',
            default => '',
        },
        ensure => present,
    }

    service{'puppet':
        ensure => running,
        require => Package[puppet],
    }
}
class puppet::openbsd {
    service{'puppet':
        provider => base,
        pattern => puppetd,
        ensure => running,
    }
}

class puppetmaster inherits puppet {
    service{'puppetmaster':
        ensure => running,
        require => Package[puppet],
    }
}

define puppet::config($source = ''){

    $real_source = $source ? {
        '' => [ "puppet://$server/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/puppet/client/puppet.conf" ],
        default => "puppet://$server/$source",
    }

    file { 'pupet_config':
        path => '/etc/puppet/puppet.conf',
        owner => root,
        group => 0,
        mode => 600,
        source => $real_source,
        notify => Service[puppet],
    }
}

define puppet::masterconfig(
    $puppetsource = '',
    $fileserversource = ''
){


    $real_puppetsource = $puppetsource ? {
        '' => 'puppet/master/puppet.conf',
        default => $source,
    }

    $real_fileserversource = $fileserversource ? {
        '' => 'puppet/master/fileserver.conf',
        default => $source,
    }

    file { 'pupet_config':
        path => '/etc/puppet/puppet.conf',
        owner => root,
        group => 0,
        mode => 600,
        source => "puppet://$server/$real_puppetsource",
        notify => [Service[puppet],Service[puppetmaster] ],
    }
    file { 'fileserver_config':
        path => '/etc/puppet/fileserver.conf',
        owner => root,
        group => 0,
        mode => 600,
        source => "puppet://$server/$real_fileserversource",
        notify => [Service[puppet],Service[puppetmaster] ],
    }
}


