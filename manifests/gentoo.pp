class puppet::gentoo inherits puppet::linux {
    Package[puppet]{
        category => 'app-admin',
    }
    Package[facter]{
        category => 'dev-ruby',
    }
    # as we use sometimes the init script to test
    Service[puppet]{
        hasstatus => false,
    }
}
