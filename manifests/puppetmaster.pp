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


  case $puppetmaster_checklastrun {
    '': { $puppetmaster_checklastrun = '40 10,22 * * *' }
  }

  if $puppetmaster_checklastrun {
    include puppet::puppetmaster::checklastrun
  } else {
    include puppet::puppetmaster::checklastrun::disable
  }

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
  } else {
    include puppet::puppetmaster::cleanup_reports::disable
  }

  if $use_shorewall {
    include shorewall::rules::puppet::master
  }
}
