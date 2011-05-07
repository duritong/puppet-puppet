class puppet::puppetmaster::package::debian inherits puppet::puppetmaster::package::base {

  package { 'puppetmaster-common':
    ensure => present,
  }

  Package['puppetmaster']{
    require => Package['puppetmaster-common']
  }
}
