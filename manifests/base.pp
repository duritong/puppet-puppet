class puppet::base {
    case $puppet_config {
        '': { $puppet_config = '/etc/puppet/puppet.conf' }
    }

    file { 'puppet_config':
        path => "$puppet_config",
        source => [ "puppet://$server/files/puppet/client/${fqdn}/puppet.conf",
                "puppet://$server/files/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/files/puppet/client/puppet.conf",
                "puppet://$server/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/puppet/client/puppet.conf" ],
        notify => Service[puppet],
        owner => root, group => 0, mode => 600;
    }
    service{'puppet':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
        pattern => puppetd,
    }
}
