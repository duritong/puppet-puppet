# manifests/puppetmaster/linux.pp

class puppet::puppetmaster::linux inherits puppet::linux {

    service{'puppetmaster':
        ensure => running,
        enable => true,
        require => [ Package[puppet] ],
    }

    Service[puppet]{
        require +> Service[puppetmaster],
    }
}
