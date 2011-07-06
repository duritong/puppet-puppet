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


  case $puppetmaster_lastruncheck_cron {
    '',undef: { $puppetmaster_lastruncheck_cron = '40 10 * * *' }
  }

  if $puppetmaster_lastruncheck_cron {
    include puppet::puppetmaster::checklastrun
  } else {
    include puppet::puppetmaster::checklastrun::disable
  }

  if $puppetmaster_mode == 'passenger' {
    include puppet::puppetmaster::passenger
  } elsif $puppetmaster_mode == 'cluster' {
    include puppet::puppetmaster::cluster
  }

  class{'puppet::puppetmaster::cleanup_reports':
    cleanup_older_than => '30',
  }

  if $use_shorewall {
    include shorewall::rules::puppet::master
  }

  if $use_munin {
    include puppet::puppetmaster::munin
  }
}
