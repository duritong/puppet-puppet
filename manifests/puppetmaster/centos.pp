# manifests/puppetmaster/centos.pp

class puppet::puppetmaster::centos inherits puppet::puppetmaster::package {
  file{'/etc/sysconfig/puppetmaster':
    source => [ "puppet://$server/modules/site-puppet/sysconfig/${fqdn}/puppetmaster",
                "puppet://$server/modules/site-puppet/sysconfig/${domain}/puppetmaster",
                "puppet://$server/modules/site-puppet/sysconfig/puppetmaster",
                "puppet://$server/modules/puppet/sysconfig/puppetmaster" ],
    notify => Service[puppetmaster],
    owner => root, group => 0, mode => 0644;
  }
}
