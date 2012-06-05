class puppet::cron::openbsd inherits puppet::openbsd {

  include puppet::cron::base

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
    command => "/usr/local/bin/puppet agent --onetime --no-daemonize --config=$puppet::config --color false ${puppet::cron::base::http_compression_str} | grep -E '(^err:|^alert:|^emerg:|^crit:)'",
    user => 'root',
    minute => split(regsubst($puppet::cron::base::crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\1'),','),
    hour => split(regsubst($puppet::cron::base::crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\2'),','),
    weekday => split(regsubst($puppet::cron::base::crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\3'),','),
    month => split(regsubst($puppet::cron::base::crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\4'),','),
    monthday => split(regsubst($puppet::cron::base::crontime,'^([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+) ([\d,\-,*,/,\,]+)$','\5'),',')
  }
}
