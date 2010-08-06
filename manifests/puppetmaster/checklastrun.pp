class puppet::puppetmaster::checklastrun {
  file{"/usr/local/bin/puppetlast":
    source => [ "puppet://$server/modules/site-puppet/master/puppetlast",
                "puppet://$server/modules/puppet/master/puppetlast" ],
    owner => root, group => 0, mode => 0700;
  }
  file{'/etc/cron.d/puppetlast.cron':
    content => "${puppetmaster_checklastrun} root /usr/local/bin/puppetlast ${puppetmaster_checklastrun_timeout}\n",
    require => File["/usr/local/bin/puppetlast"],
    owner => root, group => 0, mode => 0644,
  }
}
