# manifests/cron/base.pp
class puppet::cron::base inherits puppet::base {

  case $::operatingsystem {
    openbsd: { $stop_service = false }
    default: { $stop_service = true }
  }

  if !$puppet::cron::cron_time {
    $crontime_interval_minute = fqdn_rand(29)
    $crontime_interval_minute2 = inline_template("<%= 30+scope.lookupvar('puppet::cron::cron_time').to_i %>")
    $crontime = "${crontime_interval_minute},${crontime_interval_minute2} * * * *"
  } else {
    $crontime = $puppet::cron::cron_time
  }

  if $puppet::http_compression {
     $http_compression_str = '--http_compression'
  } else {
    $http_compression_str = ''
  }

  Service['puppet']{
    enable => false,
  }

  if $puppet::cron::stop_service == true {
    $puppet_majorversion = regsubst($::puppetversion,'^(\d+\.\d+).*$','\1')
    if $puppet_majorversion != '0.25' {
      Service['puppet']{
        ensure => stopped,
      }
    } else {
      Service['puppet']{
        hasstatus => false,
        pattern => 'puppetd',
      }
      # this works only on < 2.6
      exec { 'stop_puppet':
        command => 'kill `cat /var/run/puppet/puppetd.pid`',
        onlyif => 'test -f /var/run/puppet/puppetd.pid',
        require => Service['puppet'],
      }
    }
  }
}

