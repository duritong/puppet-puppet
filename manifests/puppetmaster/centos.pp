# manifests/puppetmaster/centos.pp

class puppet::puppetmaster::centos inherits puppet::puppetmaster::package {
  file{'/etc/sysconfig/puppetmaster':
    source => [ "puppet:///modules/site-puppet/sysconfig/${fqdn}/puppetmaster",
                "puppet:///modules/site-puppet/sysconfig/${domain}/puppetmaster",
                "puppet:///modules/site-puppet/sysconfig/puppetmaster",
                "puppet:///modules/puppet/sysconfig/puppetmaster" ],
    notify => Service[puppetmaster],
    owner => root, group => 0, mode => 0644;
  }
}
