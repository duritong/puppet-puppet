# manifests/puppetmaster/package.pp

class puppet::puppetmaster::package inherits puppet::puppetmaster::linux {
  case $operatingsystem {
    centos: { include puppet::puppetmaster::package::centos }
    debian: { include puppet::puppetmaster::package::debian }
    default: { include puppet::puppetmaster::package::base }
  }
}
