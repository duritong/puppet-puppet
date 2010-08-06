# class to use passenger for serving puppetmaster

class puppet::puppetmaster::passenger inherits puppet::puppetmaster::base {

  include ::passenger

  # A reference configuration is available at :
  # http://github.com/reductivelabs/puppet/tree/master/ext/rack

  file { ['/etc/puppet/rack', '/etc/puppet/rack/public']:
    ensure => directory,
    owner => root, group => 0, mode => 0755;
  }

  file {'/etc/puppet/rack/config.ru':
    ensure => present,
    source => [ "puppet://${server}/modules/site-puppet/master/config.ru",
                "puppet://${server}/modules/puppet/master/config.ru" ],
    owner => puppet, group => 0, mode => 0644;
  }
}
