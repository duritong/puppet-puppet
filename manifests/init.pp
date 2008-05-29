# puppet module
# original by luke kanies
# http://github.com/lak
# adaapted by puzzel itc
# merged with immerda project group's
# solution
#######################################

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
class puppet::openbsd {
    service{'puppet':
        provider => base,
        pattern => puppetd,
        ensure => running,
    }
}
