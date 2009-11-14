class puppet::puppetmaster::checklastrun {
    file{'/opt/bin/puppetlast':
        source => [ "puppet://$server/modules/site-puppet/master/puppetlast",
                    "puppet://$server/modules/puppet/master/puppetlast"],
        owner => root, group => 0, mode => 0700;
    }
    file{'/etc/cron.d/puppetlast.cron':
        content => "40 10,22 * * * root /opt/bin/puppetlast\n",
        require => File['/opt/bin/puppetlast'],
        owner => root, group => 0, mode => 0644;
    }
}
