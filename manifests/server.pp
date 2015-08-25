class newrelic::server(
    $ensure  = running
) {
    include newrelic::package
    $newrelic_license = $newrelic::license

    if $newrelic_license == undef{ fail('$newrelic_license not defined') }

    Exec['newrelic-set-license', 'newrelic-set-ssl'] {
      path +> ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
    }

    exec { "newrelic-set-license":
        unless  => "egrep -q '^license_key=${newrelic_license}$' /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set license_key=${newrelic_license}",
        notify => Service['newrelic-sysmond'];
    }

    exec { "newrelic-set-ssl":
        unless  => "egrep -q ^ssl=true$ /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set ssl=true",
        notify => Service['newrelic-sysmond'];
    }

    service { "newrelic-sysmond":
        enable  => true,
        ensure  => $ensure,
        hasstatus => true,
        hasrestart => true,
        require => Class["newrelic::package"];
    }

    # must create /var/run/newrelic/ owned by newrelic otherwise no pid file is created
    file { "/var/run/newrelic":
	ensure => "directory",
        owner => "newrelic",
        group => "newrelic",
        before => Service["newrelic-sysmond"],
    }
}
