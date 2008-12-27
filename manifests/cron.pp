# manifests/cron.pp

class puppet::cron inherits puppet {
    case $kernel {
        linux: { include puppet::cron::linux }
        openbsd: { include puppet::cron::openbsd }
        default: { include puppet::cron::base }
    }
}
