# overwrite a few things for the master
class puppet::master::base inherits puppet::base {

  file { $puppet::master::fileserver:
    source  => ["puppet:///modules/site_puppet/master/${::fqdn}/fileserver.conf",
                'puppet:///modules/site_puppet/master/fileserver.conf',
                'puppet:///modules/puppet/master/fileserver.conf' ],
    owner   => root,
    group   => puppet,
    mode    => '0640';
  }

  if !$puppet::master::config_content {
    File['puppet_config']{
      source => [ "puppet:///modules/site_puppet/master/${::fqdn}/puppet.conf",
                  'puppet:///modules/site_puppet/master/puppet.conf',
                  'puppet:///modules/puppet/master/puppet.conf' ]
    }
  }

  if $puppet::master::storeconfigs {
    include puppet::master::storeconfigs
  }


  if $puppet::master::mode == 'passenger' {
    include puppet::master::passenger
    File[$puppet::master::fileserver]{
      notify => Exec['notify_passenger_puppetmaster'],
    }
    File[puppet_config]{
      notify => Exec['notify_passenger_puppetmaster'],
    }
  } else {
    File[$puppet::master::fileserver]{
      notify => Service[puppetmaster],
    }
    File[puppet_config]{
      notify => Service[puppetmaster],
    }
  }
}
