class puppet::puppetmaster::debian inherits puppet::puppetmaster::package {

  if $puppetmaster_mode != 'passenger' {
    Service['puppetmaster'] { hasstatus => true, hasrestart => true }
  }
}
