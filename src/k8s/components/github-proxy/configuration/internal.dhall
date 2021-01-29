let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let configuration =
      { Deployment : { github-proxy : Configuration/Internal/Deployment }
      , Service : { github-proxy : Configuration/Internal/Service }
      }

in  configuration
