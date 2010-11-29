class puppet::puppetmaster::checklastrun::disable inherits puppet::puppetmaster::checklastrun {
  File['/usr/local/sbin/puppetlast']{
    source => undef,
    ensure => absent,
  }
  File['/etc/cron.d/puppetlast.cron']{
    ensure => absent,
  }
}

