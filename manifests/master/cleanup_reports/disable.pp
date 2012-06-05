class puppet::master::cleanup_reports::disable inherits puppet::master::cleanup_reports {

  File['/etc/cron.daily/puppet_reports_cleanup.sh']{
    ensure => absent,
  }
}
