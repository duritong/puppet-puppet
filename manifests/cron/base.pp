# manifests/cron/base.pp

class puppet::cron::base inherits puppet::base {
    Service['puppet']{
        ensure => stopped,
        enable => false,
    }
}
