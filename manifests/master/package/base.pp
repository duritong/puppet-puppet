class puppet::master::package::base inherits puppet::master::package {

  package { 'puppetmaster':
    ensure => $puppet::ensure_version,
  }

  if $puppet::master::mode != 'passenger' {
    Service['puppetmaster']{
      require +> Package['puppetmaster'],
    }
  }
}
