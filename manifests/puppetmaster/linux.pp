# manifests/puppetmaster/linux.pp

class puppet::puppetmaster::linux inherits puppet::linux {
    
if defined (puppet::puppetmaster::passenger) {
	$puppetmaster_servicename = "puppetmaster" }
    else {
	$puppetmaster_servicename = "apache2"
        }


    service{'puppetmaster':
        ensure => running,
        name => $puppetmaster_servicename,
	enable => true,
        require => [ Package[puppet] ],
    }

    Service[puppet]{
        require +> Service[puppetmaster],
    }
}
