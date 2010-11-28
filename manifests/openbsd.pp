class puppet::openbsd inherits puppet::base {

  File['puppet_config']{
    owner => '_puppet'
  }
  
  Service['puppet']{
    restart => '/bin/kill -HUP `/bin/cat /var/run/puppet/agent.pid`',
    stop => '/bin/kill `/bin/cat /var/run/puppet/agent.pid`',
    start => '/usr/local/bin/puppet agent',
    hasstatus => false,
    hasrestart => false,
    pattern => 'puppet agent',
  }
  
  openbsd::rc_local { 'puppetd':
    binary => '/usr/local/bin/puppet agent',
  }
  
  cron {
    'puppetd_check':
      command => '/bin/ps ax | /usr/bin/grep -v grep | /usr/bin/grep -q "puppet agent" || (sleep `echo $RANDOM/2000*60 | bc` && /usr/local/bin/puppet agent)',
      user => root,
      minute => 0;

    'puppetd_restart':
      command => 'sleep `echo $RANDOM/2000*60 | bc` && /bin/kill `/bin/cat /var/run/puppet/agent.pid`; /usr/local/bin/puppet agent',
      minute => 0,
      hour => 22,
      monthday => '*/2',
  } 
}
