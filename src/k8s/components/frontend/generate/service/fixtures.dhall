let Configuration/Internal/Service/Frontend =
      ../../configuration/internal/service/sourcegraph-frontend.dhall

let Configuration/Internal/Service/FrontendInternal =
      ../../configuration/internal/service/sourcegraph-frontend-internal.dhall

let TestConfigFrontend
    : Configuration/Internal/Service/Frontend
    = { namespace = None Text }

let TestConfigFrontendInternal
    : Configuration/Internal/Service/FrontendInternal
    = { namespace = None Text }

in  { frontend =
      { ConfigFrontend = TestConfigFrontend
      , ConfigFrontendInternal = TestConfigFrontendInternal
      }
    }
