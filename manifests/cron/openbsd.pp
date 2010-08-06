class puppet::cron::openbsd inherits puppet::openbsd {
  include puppet::cron::base 
  if !$puppet_config { $puppet_config = '/etc/puppet/puppet.conf' }

  Openbsd::Rc_local['puppetd']{
    ensure => 'absent',
  }
  Cron['puppetd_check']{
    ensure => absent,  
  }
  Cron['puppetd_restart']{
    ensure => absent,  
  }

  cron { 'puppetd_run':
    command => "/usr/local/sbin/puppetd --onetime --no-daemonize --splay --config=$puppet_config --color false | grep -E '(^err:|^alert:|^emerg:|^crit:)'",
    user => 'root',
    minute => regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\1'),
    hour => regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\2'),
    weekday => regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\3'),
    month => regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\4'),
    monthday => regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\5')
  }
}
