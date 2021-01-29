let Configuration/Internal/Service = ../../configuration/internal/service.dhall

let TestConfig
    : Configuration/Internal/Service
    = { namespace = None Text }

in  { query-runner.Config = TestConfig }
