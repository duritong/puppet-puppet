class puppet::master::munin {

  munin::plugin::deploy {
    [ 'puppetmaster_memory', 'puppet_clients' ]:
      source => "puppet/munin/puppet_",
      config => "user root
env.logfile /var/log/puppet/puppetmaster.log"
  }

}
