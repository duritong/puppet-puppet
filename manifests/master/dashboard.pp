class puppet::master::dashboard(
  $settings       = {},
  $service        = true,
  $mysql_password,
) {

  package{'puppet-dashboard':
    ensure => installed,
  } -> mysql::default_database{
    'dashboard':
      password  => mysql_password($mysql_password),
      host      => '127.0.0.1';
  } -> file{
    '/usr/share/puppet-dashboard/config/database.yml':
      content => template('puppet/master/dashboard/database.yml.erb'),
      owner   => root,
      group   => 'puppet-dashboard',
      mode    => '0640';
    '/usr/share/puppet-dashboard/config/settings.yml':
      content => template('puppet/master/dashboard/settings.yml.erb'),
      owner   => root,
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

  file{'/etc/cron.daily/puppet-dashboard_cleanup':
    content => "#/bin/bash
cd /usr/share/puppet-dashboard
RAILS_ENV=production /usr/bin/rake reports:prune upto=1 unit=mon >> /usr/share/puppet-dashboard/log/cron.log
RAILS_ENV=production /usr/bin/rake reports:prune:orphaned >> /usr/share/puppet-dashboard/log/cron.log
RAILS_ENV=production /usr/bin/rake db:raw:optimize >> /usr/share/puppet-dashboard/log/cron.log\n",
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0755',
      require => Service['puppet-dashboard-workers'];
  }

  service{'puppet-dashboard': }
  if $service {
    Service['puppet-dashboard']{
      ensure  => running,
      enable  => true,
      subscribe => File['/usr/share/puppet-dashboard/config/database.yml','/usr/share/puppet-dashboard/config/settings.yml'],
    }
  } else {
    Service['puppet-dashboard']{
      ensure  => stopped,
      enable  => false,
    }
  }
}
