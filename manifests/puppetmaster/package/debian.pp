class puppet::puppetmaster::package::debian inherits puppet::puppetmaster::package {

  Package['puppetmaster']{
    require => Package['puppetmaster-common'];
  }
}
