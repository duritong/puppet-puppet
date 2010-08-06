class puppet::puppetmaster::package::centos inherits puppet::puppetmaster::package::base {
  Package['puppetmaster']{
    name => 'puppet-server',
    alias => 'puppetmaster',
  }
}
