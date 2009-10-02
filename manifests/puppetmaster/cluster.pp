# manifests/puppetmaster/cluster.pp

class puppet::puppetmaster::cluster inherits puppet::puppetmaster {
    include puppet::puppetmaster::cluster::base
}
