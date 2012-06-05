class puppet::master::package::centos inherits puppet::master::package::base {

  Package['puppetmaster']{
    name => 'puppet-server',
    alias => 'puppetmaster',
  }
}
