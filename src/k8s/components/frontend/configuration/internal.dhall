let Configuration/Internal/Service/sourcegraph-frontend =
      ./internal/service/sourcegraph-frontend.dhall

let Configuration/Internal/Service/sourcegraph-frontend-internal =
      ./internal/service/sourcegraph-frontend-internal.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let configuration =
      { Deployment :
          { sourcegraph-frontend : Configuration/Internal/Deployment }
      , Service :
          { sourcegraph-frontend :
              Configuration/Internal/Service/sourcegraph-frontend
          , sourcegraph-frontend-internal :
              Configuration/Internal/Service/sourcegraph-frontend-internal
          }
      }

in  configuration
