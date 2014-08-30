# manifests/cron/linux.pp
class puppet::cron::linux inherits puppet::linux {

  include puppet::cron::base

  File['/etc/cron.d/puppetd']{
    source => undef,
    content => "#run puppet\n${puppet::cron::base::crontime} root output=\$(/usr/bin/puppet agent --onetime --no-daemonize --splay --config=/etc/puppet/puppet.conf --color false ${puppet::cron::base::http_compression_str}); ret=\$?; printf \"\\%s\" \"\$output\" | grep -E '(^err:|^alert:|^emerg:|^crit:)'; exit \$ret\n",
    before => Service['puppet'],
  }
}
