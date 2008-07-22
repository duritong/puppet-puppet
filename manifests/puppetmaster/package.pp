# manifests/puppetmaster/package.pp

class puppet::puppetmaster::package inherits puppet::puppetmaster::linux {
    package { puppet-server: ensure => present }

    Service[puppetmaster]{
        require +> Package[puppet-server],
    }
}
