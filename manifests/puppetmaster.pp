# manifests/puppetmaster.pp

import "storeconfigs.pp"

class puppet::puppetmaster inherits puppet {
    case $operatingsystem {
        centos,debian, redhat: { include puppet::puppetmaster::package }
        default: {
            case $kernel {
                linux: { include puppet::puppetmaster::linux }
            }
        }
    }

    File[puppet_config]{
        source => [ "puppet://$server/files/puppet/master/puppet.conf",
                    "puppet://$server/puppet/master/puppet.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
    }

    $real_puppet_fileserverconfig = $puppet_fileserverconfig ? {
        '' => "/etc/puppet/fileserver.conf",
        default => $puppet_fileserverconfig,
    }

    file { "$real_puppet_fileserverconfig":
        source => [ "puppet://$server/files/puppet/master/fileserver.conf",
                    "puppet://$server/puppet/master/fileserver.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
        owner => root, group => 0, mode => 600;
    }

    if $puppetmaster_storeconfigs {
        include puppet::puppetmaster::storeconfigs
    }

    # restart the master from time to time to avoid memory problems
    file{'/etc/cron.d/puppetmaster.cron':
        source => [ "puppet://$server/puppet/cron.d/puppetmaster.${operatingsystem}",
                    "puppet://$server/puppet/cron.d/puppetmaster" ],
        owner => root, group => 0, mode => 0644;
    }
}

class puppet::puppetmaster::linux inherits puppet::linux {

    service{'puppetmaster':
        ensure => running,
        enable => true,
        require => [ Package[puppet] ],
    }
    
    Service[puppet]{
        require +> Service[puppetmaster], 
    }
}

class puppet::puppetmaster::package inherits puppet::puppetmaster::linux {
    package { puppet-server: ensure => present }

    Service[puppetmaster]{
        require +> Package[puppet-server],
    }
}

class puppet::puppetmaster::cluster inherits puppet::puppetmaster {
    include mongrel, nginx

    Service[puppetmaster]{
        require +> Service[ngnix],
    }

    File[puppet_config] {
        require => [ Package[mongrel], Package[nginx], File[nginx_config] ],
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

define puppet::puppetmaster::hasdb(
    $dbtype = 'mysql',
    $dbname = 'puppet',
    $dbhost = 'localhost',
    # this is needed due to the collection of the databases
    $dbhostfqdn = "${fqdn}",
    $dbuser = 'puppet',
    $dbpwd = $puppet_storeconfig_password,
    $dbconnectinghost = 'locahost'
){

    case $puppet_storeconfig_password {
        '': { fail("No \$puppet_storeconfig_password is set, please set it in your manifests or site.pp to add a password") }
    }

    case $dbtype {
        'mysql': {  puppet::puppetmaster::hasdb::mysql{$name: dbname => $dbname, dbhost => $dbhost, dbuser => $dbuser, dbpwd => $dbpwd, } }
    }
}

# don't use this define use the general interface
define puppet::puppetmaster::hasdb::mysql(
    $dbname = 'puppet',
    $dbhost = 'localhost',
    $dbhostfqdn = "${fqdn}",
    $dbuser = 'puppet',
    $dbpwd,
    $dbconnectinghost = 'localhost'
){
    @@mysql_database{$dbname: 
        tag => "mysql_${dbhostfqdn}",
    }

    @@mysql_user{"${dbuser}@${dbconnectinghost}":
        password_hash => mysql_password("$dbpwd"),
        require => Mysql_database[$dbname],    
        tag => "mysql_${dbhostfqdn}",
    }


    @@mysql_grant{"${dbuser}@${dbconnectinghost}/${dbname}":
        privileges => all,
        require => Mysql_user["${dbuser}@${dbconnectinghost}"],
        tag => "mysql_${dbhostfqdn}",
    }
}
