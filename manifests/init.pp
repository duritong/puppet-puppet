# modules/puppet/manifests/init.pp - manage puppet stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "puppet": }

class puppet {
    case $kernel {
        linux: { case $operatingsystem {
                    gentoo:  { include puppet::gentoo }
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
        owner => root,
        group => 0,
        mode => 600,
        source => [ "puppet://$server/files/puppet/client/${fqdn}/puppet.conf",
                "puppet://$server/files/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/files/puppet/client/puppet.conf",
                "puppet://$server/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/puppet/client/puppet.conf" ],
        notify => Service[puppet],
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
class puppet::openbsd {
    service{'puppet':
        provider => base,
        pattern => puppetd,
        ensure => running,
    }
}

class puppetmaster inherits puppet {
    case $kernel {
        linux: { include puppetmaster::linux }
    }
    File[puppet_config]{
        source => [ "puppet://$server/files/puppet/master/puppet.conf",
                    "puppet://$server/puppet/master/puppet.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
    }

    $real_puppet_fileserverconfig = $puppet_fileserverconfig ? {
        '' => "/etc/puppet/fileserver.conf",
        default => $puppet_fileserverconfig,
    }

    file { "$real_puppet_fileserverconfig":
        owner => root,
        group => 0,
        mode => 600,
        source => [ "puppet://$server/files/puppet/master/fileserver.conf",
                    "puppet://$server/puppet/master/fileserver.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
    }
}

class puppetmaster::linux inherits puppet::linux {
    service{'puppetmaster':
        ensure => running,
        require => Package[puppet],
    }

    
    Service[puppet]{
        require +> Service[puppetmaster], 
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
