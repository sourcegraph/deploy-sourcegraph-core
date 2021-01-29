let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let configuration =
      { Deployment : { symbols : Configuration/Internal/Deployment }
      , Service : { symbols : Configuration/Internal/Service }
      }

in  configuration
