# manifests/cron/base.pp

class puppet::cron::base inherits puppet::base {
  Service['puppet']{
    enable => false,
  }

  case $operatingsystem {
    debian,openbsd,ubuntu: {
      #it's already disabled
    }
    default: {
      Service['puppet']{
        hasstatus => false,
      }
    }
  }
  exec{'stop_puppet':
    command => 'kill `cat /var/run/puppet/puppetd.pid`',
    onlyif => 'test -f /var/run/puppet/puppetd.pid',
    require => Service['puppet'],
  }
}
