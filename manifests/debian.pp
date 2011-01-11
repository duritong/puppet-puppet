class puppet::debian inherits puppet::linux {

  file { '/etc/default/puppet':
    source => [ "puppet:///modules/site-puppet/client/debian/${fqdn}/puppet",
                "puppet:///modules/site-puppet/client/debian/${domain}/puppet",
                "puppet:///modules/site-puppet/client/debian/puppet",
                "puppet:///modules/puppet/client/debian/puppet" ],
    notify => Service[puppet],
    owner => root, group => 0, mode => 0644;
  }

  case $lsbdistcodename {
    squeeze,sid: {
      $real_puppet_hasstatus = true
    }
    default: {
      $real_puppet_hasstatus = false
    }
  }
    
  Service[puppet]{
    hasstatus => $real_puppet_hasstatus,
  }
  
  File['/etc/cron.d/puppetd.cron']{
    path => '/etc/cron.d/puppetd',
  }
}


