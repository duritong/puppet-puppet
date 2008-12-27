class puppet::centos inherits puppet::linux {
    file{'/etc/sysconfig/puppet':
        source => [ "puppet://$server/files/puppet/sysconfig/${fqdn}/puppet",
                    "puppet://$server/files/puppet/sysconfig/${domain}/puppet",
                    "puppet://$server/files/puppet/sysconfig/puppet",
                    "puppet://$server/puppet/sysconfig/puppet" ],
        notify => Service[puppet],
        owner => root, group => 0, mode => 0644;
    }
}
