class puppet::puppetmaster::debian inherits puppet::puppetmaster::package {

  if $puppetmaster_mode != 'passenger' {
    case $lsbdistcodename {
      squeeze,sid: {
        Service['puppetmaster'] { hasstatus => true, hasrestart => true }
      }
    }
  }

  file { '/etc/default/puppetmaster':
    source => [ "puppet:///modules/site-puppet/master/debian/${fqdn}/puppetmaster",
                "puppet:///modules/site-puppet/master/debian/${domain}/puppetmaster",
                "puppet:///modules/site-puppet/master/debian/puppetmaster",
                "puppet:///modules/puppet/master/debian/puppetmaster" ],
    notify => Service[puppetmaster],
    owner => root, group => 0, mode => 0644;
  }
}
