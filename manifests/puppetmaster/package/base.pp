class puppet::puppetmaster::package::base inherits puppet::puppetmaster::package {

    package { 'puppetmaster':
      ensure => present,
    }

    Service['puppetmaster']{
        require +> Package['puppetmaster'],
    }

}
