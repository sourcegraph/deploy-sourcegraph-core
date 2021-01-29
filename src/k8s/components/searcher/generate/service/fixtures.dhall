let Configuration/Internal/Service = ../../configuration/internal/service.dhall

let TestConfig
    : Configuration/Internal/Service
    = { namespace = None Text, debugPort = 4321 }

in  { searcher.Config = TestConfig }
