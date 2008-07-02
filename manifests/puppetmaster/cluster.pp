# manifests/puppetmaster/cluster.pp

class puppet::puppetmaster::cluster inherits puppet::puppetmaster {
    include mongrel, nginx

    case $operatingsystem {
        centos,debian, redhat: { include puppet::puppetmaster::package::cluster }
        default: {
            case $kernel {
                linux: { include puppet::puppetmaster::linux::cluster }
            }
        }
    }


    File[puppet_config] {
        require +> [ Package[mongrel], Package[nginx], File[nginx_config] ],
    }

    case $operatingsystem {
        gentoo, centos: {
            file{"/etc/init.d/puppetmaster":
                source => "puppet://$server/puppet/init.d/puppetmaster.${operatingsystem}",
                owner => root, group => 0, mode => 0755;
            }
        }
    }
}

class puppet::puppetmaster::linux::cluster inherits puppet::puppetmaster::linux {
    Service[puppetmaster]{
        require +> Service[ngnix],
    }
}
class puppet::puppetmaster::package::cluster inherits puppet::puppetmaster::package {
    Service[puppetmaster]{
        require +> Service[ngnix],
    }
}
