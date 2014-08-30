# disable the check
class puppet::master::checklastrun::disable inherits puppet::master::checklastrun {

  File['/usr/local/sbin/puppetlast']{
    source => undef,
    ensure => absent,
  }

  File['/etc/cron.d/puppetlast']{
    ensure => absent,
  }
}

