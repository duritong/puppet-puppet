class puppet::master::base inherits puppet::base {

  file { $puppet::master::fileserverconfig:
    source => [ "puppet:///modules/site_puppet/master/${::fqdn}/fileserver.conf",
                "puppet:///modules/site_puppet/master/fileserver.conf",
                "puppet:///modules/puppet/master/fileserver.conf" ],
    owner => root, group => puppet, mode => 640;
  }

  if $puppet::master::storeconfigs {
    include puppet::master::storeconfigs
  }


  if $puppet::master::mode == 'passenger' {
    include puppet::master::passenger
    File[$puppet::master::fileserverconfig]{
      notify => Exec['notify_passenger_puppetmaster'],
    }
    File[puppet_config]{
      notify => Exec['notify_passenger_puppetmaster'],
    }
  } else {
    File[$puppet::master::fileserverconfig]{
      notify => Service[puppetmaster],
    }
    File[puppet_config]{
      notify => Service[puppetmaster],
    }
  }
}
