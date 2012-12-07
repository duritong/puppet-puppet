# deploy puppet munin plugin
class puppet::master::munin {
  munin::plugin::deploy{'puppet_':
    ensure => absent,
    source => 'puppet/munin/puppet_';
  }
  munin::plugin{
    ['puppet_clients','puppet_mem']:
      ensure  => 'puppet_',
      require => Munin::Plugin::Deploy['puppet_'],
      config  => 'user root';
  }
}
