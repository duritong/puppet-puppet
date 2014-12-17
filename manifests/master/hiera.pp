# manage hiera file
class puppet::master::hiera {
  if versioncmp($::puppetversion,'3.0') < 0 {
    require rubygems::hiera_puppet
  }
  file{"${settings::confdir}/hiera.yaml":
    source  => 'puppet:///modules/site_puppet/master/hiera.yaml',
    owner   => root,
    group   => puppet,
    mode    => '0640';
  }
}
