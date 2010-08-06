class puppet::gentoo inherits puppet::linux {
  Package[puppet]{
    category => 'app-admin',
  }
  Package[facter]{
    category => 'dev-ruby',
  }
}
