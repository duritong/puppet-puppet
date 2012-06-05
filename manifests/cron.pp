class puppet::cron(
  $cron_time,
  $config = hiera('puppet_config','/etc/puppet/puppet.conf'),
  $http_compression = hiera('puppet_http_compression',false),
  $cleanup_clientbucket = hiera('puppet_cleanup_clientbucket',false),
  $ensure_version = hiera('puppet_ensure_version', 'installed'),
  $ensure_facter_version = hiera('puppet_ensure_facter_version', 'installed'),
) {
  class{'puppet':
    config => $config,
    http_compression => $http_compression,
    cleanup_clientbucket => $cleanup_clientbucket,
    ensure_version => $ensure_version,
    ensure_facter_version => $ensure_facter_version
  }
  case $::operatingsystem {
    debian: { include puppet::cron::debian }
    openbsd: { include puppet::cron::openbsd }
    default: {
      case $::kernel {
        linux: { include puppet::cron::linux }
        default: { include puppet::cron::base }
      }
    }
  }
}
