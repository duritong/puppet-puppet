# manifests/puppetmaster/debian.pp

class puppet::puppetmaster::debian inherits puppet::puppetmaster::package {

    Package['puppet-server'] {
        name => 'puppetmaster',
        alias => 'puppet-server',
    }

}

