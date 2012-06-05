class puppet::master::package::base inherits puppet::master::package {

  package { 'puppetmaster':
    ensure => $puppet::ensure_version,
  }

  Service['puppetmaster']{
    require +> Package['puppetmaster'],
  }
}
