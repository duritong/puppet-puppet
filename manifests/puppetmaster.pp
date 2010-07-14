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

  if $use_shorewall {
    include shorewall::rules::puppet::master
  }
}
