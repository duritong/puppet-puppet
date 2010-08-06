class puppet::puppetmaster::cleanup_reports::disable inherits puppet::puppetmaster::cleanup_reports {
  File['/etc/cron.daily/puppet_reports_cleanup.sh']{
    ensure => absent,
  }
}
