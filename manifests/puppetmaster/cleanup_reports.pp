class puppet::puppetmaster::cleanup_reports(
  $cleanup_older_than = 'absent',
  $reports_dir = '/var/lib/puppet/reports/'
){
  file { '/etc/cron.daily/puppet_reports_cleanup.sh': }

  if $cleanup_older_than != 'absent' {
    File['/etc/cron.daily/puppet_reports_cleanup.sh']{
      content => "#!/bin/bash\nfind ${puppet::puppetmaster::cleanup_reports::reports_dir} -maxdepth 2 -type f -ctime +${puppet::puppetmaster::cleanup_reports::cleanup_olderthan} -exec rm {} \\;\n",
      owner => root, group => 0, mode => 0700,
    }
  } else {
    File['/etc/cron.daily/puppet_reports_cleanup.sh']{
      ensure => absent,
    }
  }
}
