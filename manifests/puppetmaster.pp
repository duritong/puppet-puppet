# manifests/puppetmaster.pp

import "storeconfigs.pp"

class puppet::puppetmaster inherits puppet {
    case $operatingsystem {
        debian: { include puppet::puppetmaster::package }
        centos: { include puppet::puppetmaster::centos }
        default: {
            case $kernel {
                linux: { include puppet::puppetmaster::linux }
            }
        }
    }
    include puppet::puppetmaster::base

    puppet::puppetmaster::checklastrun
}

class puppet::puppetmaster::base inherits puppet::base {

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
        source => [ "puppet://$server/files/puppet/master/${fqdn}/fileserver.conf",
                    "puppet://$server/files/puppet/master/fileserver.conf",
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

    munin::plugin::deploy{'puppetresources':
        source => "puppet/munin/puppetresources.mysql",
        config => "env.mysqlopts --user=$dbuser --password=$dbpwd -h $dbhost\nenv.puppetdb $dbname",
    }
}
