class puppet::base {

  if !$puppet_config { $puppet_config = '/etc/puppet/puppet.conf' }

  $puppet_majorversion = regsubst($puppetversion,'^(\d+\.\d+).*$','\1')

  case $puppet_cleanup_clientbucket {
    # if not set, don't do anything
    '',undef: {}
    default: { 
      tidy { "/var/lib/puppet/clientbucket":
        backup => false,
        recurse => true,
        rmdirs => true,
        type => mtime,
        age => "$puppet_cleanup_clientbucket";
      }
    }
  }

  file { 'puppet_config':
    path => "$puppet_config",
    source => [ "puppet:///modules/site-puppet/client/${fqdn}/puppet.conf",
                "puppet:///modules/site-puppet/client/puppet.conf.$operatingsystem",
                "puppet:///modules/site-puppet/client/puppet.conf",
                "puppet:///modules/puppet/client/${puppet_majorversion}/puppet.conf.$operatingsystem",
                "puppet:///modules/puppet/client/${puppet_majorversion}/puppet.conf",
                "puppet:///modules/puppet/client/puppet.conf.$operatingsystem",
                "puppet:///modules/puppet/client/puppet.conf" ],
    notify => Service[puppet],
    # if puppetmasterd is deployed by apache2/passenger it needs to read puppet.conf 
    # therefore it must be readable by puppet
    owner => puppet, group => 0, mode => 600;  
  }

  service { 'puppet':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
