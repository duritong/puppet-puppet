# modules/puppet/manifests/init.pp - manage puppet stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "puppet": }

class puppet {

    package{'puppet':
        name => 'puppet',
        category => $operatingsystem ? {
            gentoo => 'app-admin',
            default => '',
        },
        ensure => present,
    }

    package{'facter':
        name => 'facter',
        category => $operatingsystem ? {
            gentoo => 'dev-ruby',
            default => '',
        },
        ensure => present,
    }


    service{'puppet':
        enable => true,
        ensure => running,
        require => Package[puppet],
    }
            
    file {"$rubysitedir/puppet/parser/functions/":
        ensure => directory,
        owner => root,
        group => 0,
        mode => 744,
    }

    file { 'slash_escape_function':
        path => "$rubysitedir/puppet/parser/functions/slash_escape.rb",
        ensure => file,
        owner => 'root',
        group => 0,
        mode => 644,
        source => "puppet://$server/puppet/improvements/functions/slash_escape.rb",
   }

    file { 'puppet_patch_script':
        path => "/root/puppet_install.sh",
        ensure => absent,
    }

    file { 'puppet_patch':
        path => "/root/puppet_0.23.2-13.diff",
        ensure => absent,
    }

    file { 'puppet_patch2':
        path => "/root/puppet_module_plugin_dirs.patch",
        ensure => absent,
    }
}

class puppetmaster inherits puppet {
    Service{'puppetmaster':
        enable => true,
        ensure => running,
        require => Package[puppet],
    }
}

puppet::config($source = ''){

    $real_source = $source ? {
        '' => 'puppet/client/puppet.conf'
        default => $source,
    }

    file { 'pupet_config':
        path => '/etc/puppet/puppet.conf'
        owner => root,
        group => 0,
        mode => 600,
        source => $real_source,
        notify => Service[puppet],
    }
}

puppet::masterconfig(
    $puppetsource = '',
    $fileserversource = ''
){


    $real_puppetsource = $puppetsource ? {
        '' => 'puppet/master/puppet.conf'
        default => $source,
    }

    $real_fileserversource = $fileserversource ? {
        '' => 'puppet/master/fileserver.conf'
        default => $source,
    }

    file { 'pupet_config':
        path => '/etc/puppet/puppet.conf'
        owner => root,
        group => 0,
        mode => 600,
        source => $real_puppetsource,
        notify => [Service[puppet],Service[puppetmaster],
    }
    file { 'fileserver_config':
        path => '/etc/puppet/fileserver.conf'
        owner => root,
        group => 0,
        mode => 600,
        source => $real_fileserversource,
        notify => [Service[puppet],Service[puppetmaster],
    }
}


