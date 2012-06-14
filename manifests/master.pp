# manifests/puppetmaster.pp
class puppet::master(
  $config = '/etc/puppet/puppet.conf',
  $fileserver = '/etc/puppet/fileserver.conf',
  $http_compression = false,
  $cleanup_clientbucket = false,
  $cron_time = false,
  $ensure_version = 'installed',
  $ensure_facter_version = 'installed',
  $lastruncheck_cron = '40 10 * * *',
  $lastruncheck_ignorehosts = '',
  $lastruncheck_timeout = '',
  $lastruncheck_additionaloptions = '',
  $mode = 'webrick',
  $cleanup_reports = '30',
  $reports_dir = '/var/lib/puppet/reports',
  $manage_shorewall = false
) {
  if $cron_time {
    class{'puppet::cron':
      config => $config,
      http_compression => $http_compression,
      cleanup_clientbucket => $cleanup_clientbucket,
      cron_time => $cron_time,
      ensure_version => $ensure_version,
      ensure_facter_version => $ensure_facter_version,
      manage_shorewall => $manage_shorewall,
    }
  } else {
    class{'puppet':
      config => $config,
      http_compression => $http_compression,
      cleanup_clientbucket => $cleanup_clientbucket,
      ensure_version => $ensure_version,
      ensure_facter_version => $ensure_facter_version,
      manage_shorewall => $manage_shorewall,
    }
  }
  case $::operatingsystem {
    debian: { include puppet::master::debian }
    centos: { include puppet::master::centos }
    default: {
      case $::kernel {
        linux: { include puppet::master::linux }
      }
    }
  }

  include puppet::master::base


  if $puppet::master::lastruncheck_cron {
    include puppet::master::checklastrun
  } else {
    include puppet::master::checklastrun::disable
  }

  if $puppet::master::mode == 'passenger' {
    include puppet::master::passenger
  } elsif $puppet::master::mode == 'cluster' {
    include puppet::master::cluster
  }

  if $puppet::master::cleanup_reports {
    include puppet::master::cleanup_reports
  } else {
    include puppet::master::cleanup_reports::disable
  }

  if $manage_shorewall {
    class{'shorewall::rules::puppet::master':
      puppetserver          => $puppetserver,
      puppetserver_port     => $puppetserver_port,
      puppetserver_signport => $puppetserver_signport,
    }
  }

  if $manage_munin {
    include puppet::master::munin
  }
}
