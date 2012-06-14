define puppet::master::hasdb (
  $dbtype = 'mysql',
  $dbname = 'puppet',
  $dbhost = 'localhost',
  # this is needed due to the collection of the databases
  $dbhostfqdn = $::fqdn,
  $dbuser = 'puppet',
  $dbpwd = false,
  $dbconnectinghost = 'locahost'
) {

  if !$dbpwd { fail('No $puppet_master_storeconfig_password is set, please pass it the master class') }

  case $dbtype {
    'mysql': {  puppet::master::hasdb::mysql{$name: dbname => $dbname, dbhost => $dbhost, dbuser => $dbuser, dbpwd => $dbpwd, } }
  }
}
