# manifests/puppetmaster/cluster.pp

class puppet::puppetmaster::cluster inherits puppet::puppetmaster {
    include puppet::puppetmaster::cluster::base
}

class puppet::puppetmaster::cluster::base inherits puppet::puppetmaster::base {
    include mongrel, nginx

    File[puppet_config] {
        require +> [ Package[mongrel], Package[nginx], File[nginx_config] ],
    }
}
