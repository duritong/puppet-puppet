# manifests/puppetmaster.pp
class puppet::master(
  $config = hiera('puppet_config','/etc/puppet/puppet.conf'),
  $http_compression = hiera('puppet_http_compression',false),
  $cleanup_clientbucket = hiera('puppet_cleanup_clientbucket',false),
  $cron_time = hiera('puppet_cron_time',false),
  $ensure_version = hiera('puppet_ensure_version', 'installed'),
  $ensure_facter_version = hiera('puppet_ensure_facter_version', 'installed'),
  $lastruncheck_cron = hiera('puppet_master_lastruncheck_cron','40 10 * * *'),
  $lastruncheck_ignorehosts = hiera('puppet_master_lastruncheck_ignorehosts',''),
  $lastruncheck_timeout = hiera('puppet_master_lastruncheck_timeout',''),
  $lastruncheck_additionaloptions = hiera('puppet_master_lastruncheck_additionaloptions',''),
  $mode = hiera('puppet_master_mode','webrick'),
  $cleanup_reports = hiera('puppet_master_cleanup_reports','30'),
  $reports_dir = hiera('puppet_master_reports_dir','/var/lib/puppet/reports'),
) {
  if $cron_time {
    class{'puppet::cron':
      config => $config,
      http_compression => $http_compression,
      cleanup_clientbucket => $cleanup_clientbucket,
      cron_time => $cron_time,
      ensure_version => $ensure_version,
      ensure_facter_version => $ensure_facter_version,
    }
  } else {
    class{'puppet':
      config => $config,
      http_compression => $http_compression,
      cleanup_clientbucket => $cleanup_clientbucket,
      ensure_version => $ensure_version,
      ensure_facter_version => $ensure_facter_version,
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

  if hiera('use_shorewall',false) {
    include shorewall::rules::puppet::master
  }

  if hiera('use_munin',false) {
    include puppet::master::munin
  }
}
