class puppet::base::master inherits puppet::base {
  File[puppet_config]{
    source => [ "puppet:///modules/site_puppet/master/puppet.conf",
                "puppet:///modules/puppet/master/puppet.conf" ],
  }
}
