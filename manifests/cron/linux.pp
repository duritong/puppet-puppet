# manifests/cron/linux.pp 
class puppet::cron::linux inherits puppet::linux {
    include puppet::cron::base
    case $puppet_config {
        '': { $puppet_config = '/etc/puppet/puppet.conf' }
    }
    
    case $puppet_crontime {
        '': { $puppet_crontime = '0,30 * * * *' }
    }


    File['/etc/cron.d/puppetd.cron']{
        source => undef,
        content => "# run puppet
$puppet_crontime root /usr/sbin/puppetd --onetime --no-daemonize --splay --config=$puppet_config --color false | grep -E '(^err:|^alert:|^emerg:|^crit:)'\n",
    }
}
