define puppet::master::hasdb (
  $dbtype = 'mysql',
  $dbname = 'puppet',
  $dbhost = 'localhost',
  # this is needed due to the collection of the databases
  $dbhostfqdn = $::fqdn,
  $dbuser = 'puppet',
  $dbpwd = hiera('puppet_master_storeconfigs_password',false),
  $dbconnectinghost = 'locahost'
) {

  if !$dbpwd { fail("No \$puppet_master_storeconfig_password is set, please set it in your hiera database") }

  case $dbtype {
    'mysql': {  puppet::master::hasdb::mysql{$name: dbname => $dbname, dbhost => $dbhost, dbuser => $dbuser, dbpwd => $dbpwd, } }
  }
}
