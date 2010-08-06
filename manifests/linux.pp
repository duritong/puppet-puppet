class puppet::linux inherits puppet::base {

  if !$puppet_ensure_version { $puppet_ensure_version = 'installed' }
  package{ 'puppet':
    ensure => $puppet_ensure_version,
  }

  if !$facter_ensure_version { $facter_ensure_version = 'installed' }
  package{ 'facter':
    ensure => $facter_ensure_version,
  }

  # package bc needed for cron job
  include bc
  Service['puppet']{
    require => Package[puppet],
  }

  include ::cron

  file{'/etc/cron.d/puppetd.cron':
    source => [ "puppet://$server/modules/puppet/cron.d/puppetd.${operatingsystem}",
                "puppet://$server/modules/puppet/cron.d/puppetd" ],
    owner => root, group => 0, mode => 0644,
    notify => Service['cron'];
  }
}
