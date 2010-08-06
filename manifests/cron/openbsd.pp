class puppet::cron::openbsd inherits puppet::openbsd {
  include puppet::cron::base 
  if !$puppet_config { $puppet_config = '/etc/puppet/puppet.conf' }

  if !$puppet_crontime {
    $puppet_crontime_interval_minute = fqdn_rand(29)
    $puppet_crontime_interval_minute2 = inline_template('<%= 30+puppet_crontime_interval_minute.to_i %>')
    $puppet_crontime = '${puppet_crontime_interval_minute},${puppet_crontime_interval_minute2} * * * *'
  }

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
    minute => split(regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\1'),','),
    hour => split(regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\2'),','),
    weekday => split(regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\3'),','),
    month => split(regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\4'),','),
    monthday => split(regsubst($puppet_crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\5'),',')
  }
}
