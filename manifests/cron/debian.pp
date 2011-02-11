class puppet::cron::debian inherits puppet::cron::linux {

  File['/etc/cron.d/puppetd.cron']{
    path => '/etc/cron.d/puppetd',
  }

}
