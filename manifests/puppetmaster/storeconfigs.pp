# This class sets up the necessary ActiveRecord bits
# so storeconfigs works.
class puppet::puppetmaster::storeconfigs {
    include rails
    include mysql::server
   
    case $operatingsystem {
       debian:    { package { libmysql-ruby: ensure => present } }
    	
	}


}
