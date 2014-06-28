# debian specific things
class puppet::debian inherits puppet::linux {

  file { '/etc/default/puppet':
    source  => ["puppet:///modules/site_puppet/client/debian/${::fqdn}/puppet",
                "puppet:///modules/site_puppet/client/debian/${::domain}/puppet",
                'puppet:///modules/site_puppet/client/debian/puppet',
                'puppet:///modules/puppet/client/debian/puppet' ],
    notify  => Service[puppet],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }

  package{ 'puppet-common':
    ensure => $puppet::ensure_version,
  }

  Package['puppet']{
    require => Package['puppet-common']
  }
}


