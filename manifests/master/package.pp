# manifests/puppetmaster/package.pp

class puppet::master::package inherits puppet::master::linux {
  case $::operatingsystem {
    centos: { include puppet::master::package::centos }
    debian: { include puppet::master::package::debian }
    default: { include puppet::master::package::base }
  }
}
