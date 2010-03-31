class puppet::linux inherits puppet::base {

    $real_puppet_version = $puppet_version ? {
        '' => 'present',
        default => $puppet_version,
    }
    
    $real_facter_version = $facter_version ? {
        '' => 'present',
        default => $facter_version,
    }

    package{ 'puppet':
        ensure => $real_puppet_version,
    }
    
    package{ 'facter':
        ensure => $real_facter_version,
    }

    # package bc needed for cron
    include bc
    Service['puppet']{
        require => Package[puppet],
    }


    file{'/etc/cron.d/puppetd.cron':
        source => [ "puppet://$server/modules/puppet/cron.d/puppetd.${operatingsystem}",
                    "puppet://$server/modules/puppet/cron.d/puppetd" ],
        owner => root, group => 0, mode => 0644;
    }
}
