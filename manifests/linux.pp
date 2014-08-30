# puppet on linux
class puppet::linux inherits puppet::base {

  package { 'puppet':
    ensure => $puppet::ensure_version,
  }

  package { 'facter':
    ensure => $puppet::ensure_facter_version,
  }

  Service['puppet']{
    require => Package[puppet],
  }

  file { '/etc/cron.d/puppetd':
    source  => ['puppet:///modules/site_puppet/cron.d/puppetd',
                "puppet:///modules/puppet/cron.d/puppetd.${::operatingsystem}",
                'puppet:///modules/puppet/cron.d/puppetd' ],
    owner   => root,
    group   => 0,
    mode    => '0644',
  }
}
