# a config.ru, for use with every rack-compatible webserver.
# SSL needs to be handled outside this, though.

# if puppet is not in your RUBYLIB:
# $:.unshift('/opt/puppet/lib')

$0 = "puppetmasterd"
require 'puppet'

# logs to file instead of syslog
#Puppet::Util::Log.newdestination("/var/log/puppet/puppetmasterd.log")

# if you want debugging:
#ARGV << "--debug"

ARGV << "--rack"

# in some setups puppetmasterd doesn't seem to read the puppet.conf 
# config at startup, then you need to pass these options:
ARGV << "--vardir" << "/var/lib/puppet"
ARGV << "--ssldir" << "/var/lib/puppet/ssl"

# if you use puppet-dashboard:
#ARGV << "--reports" << "puppet_dashboard"

require 'puppet/application/puppetmasterd'
# we're usually running inside a Rack::Builder.new {} block,
# therefore we need to call run *here*.
run Puppet::Application[:puppetmasterd].run
