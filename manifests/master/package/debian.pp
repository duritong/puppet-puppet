class puppet::master::package::debian inherits puppet::master::package::base {

  package { 'puppetmaster-common':
    ensure => present,
  }

  Package['puppetmaster']{
    require => Package['puppetmaster-common']
  }
}
