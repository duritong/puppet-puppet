# debian master
class puppet::master::debian inherits puppet::master::package {

  if $puppet::master::mode != 'passenger' {
    Service['puppetmaster'] { hasstatus => true, hasrestart => true }
  }

  file { '/etc/default/puppetmaster':
    source  => ["puppet:///modules/site_puppet/master/debian/${::fqdn}/puppetmaster",
                "puppet:///modules/site_puppet/master/debian/${::domain}/puppetmaster",
                'puppet:///modules/site_puppet/master/debian/puppetmaster',
                'puppet:///modules/puppet/master/debian/puppetmaster' ],
    notify  => Service[puppetmaster],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
}
