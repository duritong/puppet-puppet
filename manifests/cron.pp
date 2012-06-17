class puppet::cron(
  $cron_time,
  $stop_service = true,
  $config = '/etc/puppet/puppet.conf',
  $http_compression = 'puppet_http_compression',
  $cleanup_clientbucket = false,
  $ensure_version = 'installed',
  $ensure_facter_version = 'installed',
  $manage_shorewall = false,
  $shorewall_puppetmaster = "puppet.${domain}",
  $shorewall_puppetmaster_port = '8140',
  $shorewall_puppetmaster_signport = '8141'
) {
  class{'puppet':
    config                          => $config,
    http_compression                => $http_compression,
    cleanup_clientbucket            => $cleanup_clientbucket,
    ensure_version                  => $ensure_version,
    ensure_facter_version           => $ensure_facter_version,
    manage_shorewall                => $manage_shorewall,
    shorewall_puppetmaster          => $shorewall_puppetmaster,
    shorewall_puppetmaster_port     => $shorewall_puppetmaster_port,
    shorewall_puppetmaster_signport => $shorewall_puppetmaster_signport,
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
