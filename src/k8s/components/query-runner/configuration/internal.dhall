let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let configuration =
      { Deployment : { query-runner : Configuration/Internal/Deployment }
      , Service : { query-runner : Configuration/Internal/Service }
      }

in  configuration
