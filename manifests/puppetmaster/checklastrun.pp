class puppet::puppetmaster::checklastrun {

  $puppet_lastruncheck_ignorehosts_str = $puppet_lastruncheck_ignorehosts ? {
    '' => '',
    undef => '',
    default => "--ignore-hosts ${puppet_lastruncheck_ignorehosts}"
  }

  $puppet_lastruncheck_timeout_str = $puppet_lastruncheck_timeout ? {
    '' => '',
    undef => '',
    default => "--timeout ${puppet_lastruncheck_timeout}"
  }

  file{
    '/usr/local/sbin/puppetlast':
      source => [ "puppet:///modules/puppet/master/lastruncheck" ],
      owner => root, group => 0, mode => 0700;

    '/etc/cron.d/puppetlast.cron':
      content => "${puppetmaster_lastruncheck_cron} root /usr/local/sbin/puppetlast ${puppet_lastruncheck_timeout_str} ${puppet_lastruncheck_ignorehosts_str} ${$puppet_lastruncheck_additionaloptions}\n",
      require => File["/usr/local/bin/puppetlast"],
      owner => root, group => 0, mode => 0644,
  }
}
