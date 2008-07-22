# manifests/puppetmaster/centos.pp

class puppet::puppetmaster::centos inherits puppet::puppetmaster::package {
    file{'/etc/sysconfig/puppetmaster':
        source => [ "puppet://$server/files/puppet/sysconfig/${fqdn}/puppetmaster",
                    "puppet://$server/files/puppet/sysconfig/${domain}/puppetmaster",
                    "puppet://$server/files/puppet/sysconfig/puppetmaster",
                    "puppet://$server/puppet/sysconfig/puppetmaster" ],
        notify => Service[puppetmaster],
        owner => root, group => 0, mode => 0644;
    }
}
