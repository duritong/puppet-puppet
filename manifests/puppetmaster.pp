# manifests/puppetmaster.pp
class puppet::puppetmaster inherits puppet {
  case $operatingsystem {
    debian: { include puppet::puppetmaster::debian }
    centos: { include puppet::puppetmaster::centos }
    default: {
      case $kernel {
        linux: { include puppet::puppetmaster::linux }
      }
    }
  }

  include puppet::puppetmaster::base
  include puppet::puppetmaster::checklastrun

  if $puppetmaster_mode == 'passenger' {
    include puppet::puppetmaster::pasenger
  } elsif $puppetmaster_mode == 'cluster' {
    include puppet::puppetmaster::cluster
  }

  case $puppetmaster_cleanup_reports {
    '': { $puppetmaster_cleanup_reports = '30' }
  }

  if $puppetmaster_cleanup_reports {
    include puppet::puppetmaster::cleanup_reports
  }

  if $use_shorewall {
    include shorewall::rules::puppet::master
  }
}
