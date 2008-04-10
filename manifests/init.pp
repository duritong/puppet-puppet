# modules/puppet/manifests/init.pp - manage puppet stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "puppet": }

class puppet {
    case $kernel {
        linux: { include puppet::linux}
        openbsd: { include puppet::openbsd}
    }

    $real_puppet_conf_source = $puppet_conf_source ? {
        '' => [ "puppet://$server/files/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/files/puppet/client/puppet.conf", 
                "puppet://$server/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/puppet/client/puppet.conf" ],
        default => "puppet://$server/$source",
    }

    file { 'puppet_config':
        path => '/etc/puppet/puppet.conf',
        owner => root,
        group => 0,
        mode => 600,
        source => $real_puppet_conf_source,
        notify => Service[puppet],
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

    file{'/etc/cron.d/puppetd':
        owner => root,
        group => 0,
        mode => 0644,
        source => [ "puppet://$server/files/puppet/cron.d/puppetd",
                    "puppet://$server/puppet/cron.d/puppetd.$operatingsystem",
                    "puppet://$server/puppet/cron.d/puppetd"
        ],
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

    
    Service[puppet]{
        require +> Service[puppetmaster], 
    }

    $real_puppetmaster_conf_source = $puppet_conf_source ? {
        '' => [ "puppet://$server/files/puppet/master/puppet.conf",
                "puppet://$server/puppet/master/puppet.conf" ],
        default => "puppet://$server/$puppet_conf_source",
    }

    File[puppet_config]{
        source => $real_puppetmaster_conf_source,
        notify => [Service[puppet],Service[puppetmaster] ],
    }

    $real_puppet_fileserver_source = $puppet_fileserver_source ? {
        '' => [ "puppet://$server/files/puppet/master/fileserver.conf",
                "puppet://$server/puppet/master/fileserver.conf" ],
        default => "puppet://$server/$puppet_fileserver_source"
    }

    file { '/etc/puppet/fileserver.conf':
        owner => root,
        group => 0,
        mode => 600,
        source => $real_puppet_fileserver_source ,
        notify => [Service[puppet],Service[puppetmaster] ],
    }
}

class puppetmaster::cluster inherits puppetmaster {
    include mongrel, nginx

    Service[puppetmaster]{
        require +> Service[ngnix],
    }

    File[puppet_config] {
        require => [ Package[mongrel], Package[nginx], File[nginx_config] ],
    }

    file{"/etc/init.d/puppetmaster":
        source => [ "puppet://$server/files/puppet/cluster/init.d/puppetmaster-${fqdn}",
                    "puppet://$server/puppet/cluster/init.d/puppetmaster.${operatingsystem}",
                    "puppet://$server/puppet/cluster/init.d/puppetmaster" ],
        owner => root,
        group => 0,
        mode => 0755,
        require => [ Package[puppet], Package[mongrel], Package[nginx], File[nginx_config] ], 
        notify => Service[puppetmaster],
    }
}
