# run puppet agent as cron
class puppet::cron(
  $cron_time,
  $stop_service                     = true,
  $config                           = '/etc/puppet/puppet.conf',
  $config_content                   = false,
  $http_compression                 = 'puppet_http_compression',
  $cleanup_clientbucket             = false,
  $ensure_version                   = 'installed',
  $ensure_facter_version            = 'installed',
  $shorewall_puppetmaster           = false,
  $shorewall_puppetmaster_port      = '8140',
  $shorewall_puppetmaster_signport  = '8141'
) {
  class{'puppet':
    config                          => $config,
    config_content                  => $config_content,
    http_compression                => $http_compression,
    cleanup_clientbucket            => $cleanup_clientbucket,
    ensure_version                  => $ensure_version,
    ensure_facter_version           => $ensure_facter_version,
    shorewall_puppetmaster          => $shorewall_puppetmaster,
    shorewall_puppetmaster_port     => $shorewall_puppetmaster_port,
    shorewall_puppetmaster_signport => $shorewall_puppetmaster_signport,
  }
  case $::operatingsystem {
    openbsd: { include puppet::cron::openbsd }
    default: {
      case $::kernel {
        linux: { include puppet::cron::linux }
        default: { include puppet::cron::base }
      }
    }
  }
}
