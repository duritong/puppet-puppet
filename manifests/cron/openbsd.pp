class puppet::cron::openbsd inherits puppet::openbsd {
    include puppet::cron::base 
    case $puppet_config {
        '': { $puppet_config = '/etc/puppet/puppet.conf' }
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
        command => "/usr/local/bin/puppetd --onetime --no-daemonize --splay --config=$puppet_config --color false | grep -E '(^err:|^alert:|^emerg:|^crit:)'",
        user => 'root',
        minute => [0,30],
    }

}
