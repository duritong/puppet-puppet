# class to use passenger for serving puppetmaster
class puppet::master::passenger inherits puppet::master {

  include ::passenger

  # A reference configuration is available at :
  # http://github.com/reductivelabs/puppet/tree/master/ext/rack
  file {
    ['/etc/puppet/rack', '/etc/puppet/rack/public' ]:
      ensure  => directory,
      owner   => root,
      group   => 0,
      mode    => '0755';
    '/etc/puppet/rack/tmp':
      ensure  => directory,
      owner   => puppet,
      group   => 0,
      mode    => '0750';
    '/etc/puppet/rack/config.ru':
      source  => ['puppet:///modules/site_puppet/master/config.ru',
                  'puppet:///modules/puppet/master/config.ru' ],
      owner   => puppet,
      group   => 0,
      mode    => '0644';
  }
}
