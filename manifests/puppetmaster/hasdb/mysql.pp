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
