# check for last run
class puppet::master::checklastrun {

  $puppet_lastruncheck_ignorehosts_str = $puppet::master::lastruncheck_ignorehosts ? {
    '' => '',
    undef => '',
    default => "--ignore-hosts ${puppet::master::lastruncheck_ignorehosts}"
  }

  $puppet_lastruncheck_timeout_str = $puppet::master::lastruncheck_timeout ? {
    '' => '',
    undef => '',
    default => "--timeout ${puppet::master::lastruncheck_timeout}"
  }

  file{
    '/usr/local/sbin/puppetlast':
      source  => 'puppet:///modules/puppet/master/lastruncheck',
      owner   => root,
      group   => 0,
      mode    => '0700';
    '/etc/cron.d/puppetlast':
      content => "${puppet::master::lastruncheck_cron} root /usr/local/sbin/puppetlast ${puppet_lastruncheck_timeout_str} ${puppet_lastruncheck_ignorehosts_str} ${puppet::master::lastruncheck_additionaloptions} | grep -Ev '^OK: '\n",
      require => File['/usr/local/sbin/puppetlast'],
      owner   => root,
      group   => 0,
      mode    => '0644';
  }
}
