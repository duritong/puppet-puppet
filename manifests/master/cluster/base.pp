class puppet::master::cluster::base inherits puppet::master::base {

  include mongrel, nginx

  File[puppet_config] {
    require +> [ Package[mongrel], Package[nginx], File[nginx_config] ],
  }
}

