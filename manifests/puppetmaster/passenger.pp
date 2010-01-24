# class to use passenger for serving puppetmaster

class puppet::puppetmaster::passenger {
   
    case $operatingsystem {
        debian:    { include puppet::puppetmaster::passenger::debian  }
        defaults: { include  puppet::puppetmaster::passenger::base }    	
	}
}

class puppet::puppetmaster::passenger::debian inherits puppet::puppetmaster::passenger::base {
    # according to http://github.com/reductivelabs/puppet/tree/master/ext/rack rack needs 
    # to be version >= 1.0.0 . lenny-backports provide it
    package { "librack-ruby": ensure => "1.0.0-2~bpo50+1" } 
    package { "librack-ruby1.8": ensure => "1.0.0-2~bpo50+1" } 
    
    apache::config::global{ 'puppet-apache2-passenger.conf': }
    apache::debian::module { 'ssl': ensure    => present }
    apache::debian::module { 'passenger': ensure    => present }
    apache::debian::module { 'headers': ensure    => present }
}

class puppet::puppetmaster::passenger::base {
    notice ( "class puppet::puppetmaster::passenger::base needs to be configured for using passenger with non-debian OS !" )

    include apache
    include passenger::apache
    

    # http://github.com/reductivelabs/puppet/tree/master/ext/rack
    file { ["/etc/puppet/rack", "/etc/puppet/rack/public"]:
      ensure => directory,
      mode => 0755,
      owner => root,
      group => root,
    }
    file { "/etc/puppet/rack/config.ru":
      ensure => present,
      source => "puppet:///modules/puppet/master/config.ru",
      mode => 0644,
      owner => puppet,
      group => root,
    }
}

