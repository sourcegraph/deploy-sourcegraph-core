let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let configuration =
      { Deployment : { searcher : Configuration/Internal/Deployment }
      , Service : { searcher : Configuration/Internal/Service }
      }

in  configuration
