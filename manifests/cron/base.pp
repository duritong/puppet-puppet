# manifests/cron/base.pp
class puppet::cron::base inherits puppet::base {

  case $operatingsystem {
    debian: { if $lsbdistcodename != 'lenny' { $stop_service = true } else { $stop_service = false }  }
    openbsd, ubuntu: { $stop_service = false }
    default: { $stop_service = true }
  }
        
  Service['puppet']{
    enable => false,
  }

  if $stop_service == true {
    $puppet_majorversion = regsubst($puppetversion,'^(\d+\.\d+).*$','\1')
    if $puppet_majorversion == '2.6' {  
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

