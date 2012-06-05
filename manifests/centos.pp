class puppet::centos inherits puppet::linux {

  file { '/etc/sysconfig/puppet':
    source => [ "puppet:///modules/site_puppet/sysconfig/${::fqdn}/puppet",
                "puppet:///modules/site_puppet/sysconfig/${::domain}/puppet",
                "puppet:///modules/site_puppet/sysconfig/puppet",
                "puppet:///modules/puppet/sysconfig/puppet" ],
    notify => Service[puppet],
    owner => root, group => 0, mode => 0644;
  }
}
