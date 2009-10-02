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
