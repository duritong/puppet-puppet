class puppet::puppetmaster::checklastrun::disable inherits puppet::puppetmaster::checklastrun {

  File['/usr/local/bin/puppetlast']{
    ensure => absent,
  }
  File['/etc/cron.d/puppetlast.cron']{
    ensure => absent,
  }
}

