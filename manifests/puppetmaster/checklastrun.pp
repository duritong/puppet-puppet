class puppet::puppetmaster::checklastrun {
    include ibp::opt::bin
    file{'/opt/bin/puppetlast':
        source => [ "puppet://$server/files/puppet/master/puppetlast",
                    "puppet://$server/puppet/master/puppetlast"],
        owner => root, group => 0, mode =0700;
    }
    file{'/etc/cron.d/puppetlast.cron':
        content => "40 22 * * * root /opt/bin/puppetlast"
        require => File['/opt/bin/puppetlast'],
        owner => root, group => 0, mode => 0644;
    }
}
