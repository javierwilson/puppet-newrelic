class newrelic(
    $license  = $::newrelic_license,
    $ensure   = running,
) {
    include newrelic::repo
    include newrelic::package
    class{'newrelic::server':
        ensure  => $ensure
    }
}
