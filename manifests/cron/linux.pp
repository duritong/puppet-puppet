# manifests/cron/linux.pp 
class puppet::cron::linux inherits puppet::linux {
    include puppet::cron::base
    case $puppet_config {
        '': { $puppet_config = '/etc/puppet/puppet.conf' }
    }
    File['/etc/cron.d/puppetd.cron']{
        source => undef,
        content => "# run puppet
0,30 * * * * root puppetd --onetime --no-daemonize --splay true --config=$puppet_config",
    }
}
