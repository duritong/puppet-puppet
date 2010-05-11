# manifests/puppetmaster/linux.pp

class puppet::puppetmaster::linux inherits puppet::linux {
    
    if defined (puppet::puppetmaster::passenger) {
	service{'puppetmaster':
	    ensure => running,
	    #name => apache2,
	    #enable => true,
	    pattern => 'apache2',
	    hasstatus => true,
	    start => '/etc/init.d/apache2 start',
	    stop => '/etc/init.d/apache2 start',
	    restart => '/etc/init.d/apache2 restart',
	    status => 'pgrep apache2',
	    require => [ Package[puppet] ],
	}
    }
    else {
	service{'puppetmaster':
	    ensure => running,
	    enable => true,
	    require => [ Package[puppet] ],
	}
    }
    Service[puppet]{
        require +> Service[puppetmaster],
    }
}
