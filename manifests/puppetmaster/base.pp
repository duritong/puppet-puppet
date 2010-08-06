class puppet::puppetmaster::base inherits puppet::base {
  File[puppet_config]{
    source => [ "puppet://$server/modules/site-puppet/master/puppet.conf",
                "puppet://$server/modules/puppet/master/puppet.conf" ],
    notify => Service[puppetmaster],
  }

  if !$puppet_fileserverconfig { $puppet_fileserverconfig  = '/etc/puppet/fileserver.conf' }

  file { "$puppet_fileserverconfig":
    source => [ "puppet://$server/modules/site-puppet/master/${fqdn}/fileserver.conf",
                "puppet://$server/modules/site-puppet/master/fileserver.conf",
                "puppet://$server/modules/puppet/master/fileserver.conf" ],
    owner => root, group => puppet, mode => 640;
  } 

  if $puppetmaster_storeconfigs {
    include puppet::puppetmaster::storeconfigs
  }


  if $puppetmaster_mode == 'passenger' {
    include puppet::puppetmaster::pasenger
    File[$puppet_fileserverconfig]{
      notify => Exec['notify_passenger_puppetmaster'],
    }
    File[puppet_config]{
      notify => Exec['notify_passenger_puppetmaster'],
    }
  } else {
    File[$puppet_fileserverconfig]{
      notify => Service[puppetmaster],
    }
    File[puppet_config]{
      notify => Service[puppetmaster],
    }
  }

  # clean up reports older than 30 days
  file{'/etc/cron.daily/puppet_reports_cleanup.sh':
    content => "#!/bin/bash\nfind /var/log/puppet/reports/ -maxdepth 2 -type f -ctime +30 -exec rm {} \\;\n",
    owner => root, group => 0, mode => 0700;
  }
}
