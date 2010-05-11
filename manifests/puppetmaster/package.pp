# manifests/puppetmaster/package.pp

class puppet::puppetmaster::package inherits puppet::puppetmaster::linux {
    case $operatingsystem {
	 debian: { $puppetmaster_package="puppetmaster" }
         default: { $puppetmaster_package="puppet-server" }
    }

    package { $puppetmaster_package: ensure => present }

    Service[puppetmaster]{
        require +> Package[$puppetmaster_package],
    }
}
