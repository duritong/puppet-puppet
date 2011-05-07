class puppet::puppetmaster::package::debian inherits puppet::puppetmaster::package::base {

  Package['puppetmaster']{
    require => Package['puppetmaster-common']
  }
}
