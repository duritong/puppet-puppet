class puppet::puppetmaster::checklastrun {
    case $operatingsystem {
         debian,ubuntu: { $puppetlast_dest = "/usr/local/bin/puppetlast" }
         default: { $puppetlast_dest = "/opt/bin/puppetlast" }
    }




    file{"$puppetlast_dest":
        source => [ "puppet://$server/modules/site-puppet/master/puppetlast",
                    "puppet://$server/modules/puppet/master/puppetlast"],
        owner => root, group => 0, mode => 0700;
    }
    file{'/etc/cron.d/puppetlast.cron':
        content => "40 10,22 * * * root $puppetlast_dest\n",
        require => File["$puppetlast_dest"],
        owner => root, group => 0, mode => 0644,
	notify => service["cron"];
    }
}
