# manifests/puppetmaster/centos.pp
class puppet::master::centos inherits puppet::master::package {
  file { '/etc/sysconfig/puppetmaster':
    source  => [  "puppet:///modules/site_puppet/sysconfig/${::fqdn}/puppetmaster",
                  "puppet:///modules/site_puppet/sysconfig/${::domain}/puppetmaster",
                  'puppet:///modules/site_puppet/sysconfig/puppetmaster',
                  'puppet:///modules/puppet/sysconfig/puppetmaster' ],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  if $puppet::master::mode != 'passenger' {
    File['/etc/sysconfig/puppetmaster']{
      notify => Service[puppetmaster],
    }
  }
}
