let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let configuration =
      { Deployment : { jaeger : Configuration/Internal/Deployment }
      , Service :
          { jaeger-collector : Configuration/Internal/Service
          , jaeger-query : Configuration/Internal/Service
          }
      }

in  configuration
