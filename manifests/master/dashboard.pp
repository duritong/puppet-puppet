class puppet::master::dashboard(
  $settings       = {},
  $service        = true,
  $mysql_password,
) {

  package{'puppet-dashboard':
    ensure => installed,
  } -> mysql::default_database{
    'dashboard':
      password => $mysql_password;
  } -> file{
    '/usr/share/puppet-dashboard/config/database.yaml':
      content => template('puppet/master/dashboard/database.yaml.erb'),
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0640';
    '/usr/share/puppet-dashboard/config/settings.yaml':
      content => template('puppet/master/dashboard/settings.yaml.erb'),
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0640';
  } ~> exec{
    'rake RAILS_ENV=production db:migrate':
      cwd         => '/usr/share/puppet-dashboard',
      user        => 'puppet-dashboard',
      refreshonly => true;
  } -> service{
    'puppet-dashboard-workers':
      ensure  => running,
      enable  => true;
  }

  service{'puppet-dashboard': }
  if $service {
    Service['puppet-dashboard']{
      ensure  => running,
      enable  => true,
      subscribe => File['/usr/share/puppet-dashboard/config/database.yaml','/usr/share/puppet-dashboard/config/settings.yaml'],
    }
  } else {
    Service['puppet-dashboard']{
      ensure  => stopped,
      enable  => false,
    }
  }
}
