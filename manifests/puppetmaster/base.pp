class puppet::puppetmaster::base inherits puppet::base {

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
        source => [ "puppet://$server/files/puppet/master/${fqdn}/fileserver.conf",
                    "puppet://$server/files/puppet/master/fileserver.conf",
                    "puppet://$server/puppet/master/fileserver.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
        owner => root, group => 0, mode => 600;
    }

    if $puppetmaster_storeconfigs {
        include puppet::puppetmaster::storeconfigs
    }

    # restart the master from time to time to avoid memory problems
    file{'/etc/cron.d/puppetmaster.cron':
        source => [ "puppet://$server/puppet/cron.d/puppetmaster.${operatingsystem}",
                    "puppet://$server/puppet/cron.d/puppetmaster" ],
        owner => root, group => 0, mode => 0644;
    }

    file{'/etc/cron.daily/puppet_reports_cleanup.sh':
        content => "#!/bin/bash\nfind /var/log/puppet/reports/ -maxdepth 2 -type f -ctime +30 -exec rm {} \\;\n",
        owner => root, group => 0, mode => 0700;
    }
}
