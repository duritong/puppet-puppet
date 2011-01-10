class puppet::puppetmaster::munin {

  munin::plugin::deploy {
    [ 'puppetmaster_memory', 'puppet_clients' ]:
      source => "puppet/munin/puppet_",
      config => "user root"
  }

}
