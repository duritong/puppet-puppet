class puppet::base {
  if !$puppet_config { $puppet_config = '/etc/puppet/puppet.conf' }

  file { 'puppet_config':
    path => "$puppet_config",
    source => [ "puppet://$server/modules/site-puppet/client/${fqdn}/puppet.conf",
                "puppet://$server/modules/site-puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/modules/site-puppet/client/puppet.conf",
                "puppet://$server/modules/puppet/client/puppet.conf.$operatingsystem",
                "puppet://$server/modules/puppet/client/puppet.conf" ],
    notify => Service[puppet],
	  # if puppetmasterd is deployed by apache2/passenger it needs to read puppet.conf 
	  # therefore it must be readable by puppet
    owner => puppet, group => 0, mode => 600;  
  }
  service{'puppet':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    pattern => puppetd,
  }
}
