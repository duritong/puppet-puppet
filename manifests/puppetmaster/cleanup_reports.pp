class puppet::puppetmaster::cleanup_reports {

  # clean up reports older than $puppetmaster_cleanup_reports days
  file { '/etc/cron.daily/puppet_reports_cleanup.sh':
    content => "#!/bin/bash\nfind /var/log/puppet/reports/ -maxdepth 2 -type f -ctime +${puppetmaster_cleanup_reports} -exec rm {} \\;\n",
    owner => root, group => 0, mode => 0700;
  }
}
