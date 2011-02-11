class puppet::linux inherits puppet::base {

  if !$puppet_ensure_version { $puppet_ensure_version = 'installed' }
  package{ 'puppet':
    ensure => $puppet_ensure_version,
  }

  if !$facter_ensure_version { $facter_ensure_version = 'installed' }
  package{ 'facter':
    ensure => $facter_ensure_version,
  }

  Service['puppet']{
    require => Package[puppet],
  }

  # this is to clean up an invalid cron name from a previous version
  # at some point, this should be removed
  file { '/etc/cron.d/puppetd.cron': ensure => absent }
  
  file { '/etc/cron.d/puppetd':
    source => [ "puppet:///modules/site-puppet/cron.d/puppetd",
                "puppet:///modules/puppet/cron.d/puppetd.${operatingsystem}",
                "puppet:///modules/puppet/cron.d/puppetd" ],
    owner => root, group => 0, mode => 0644,
  }
}
