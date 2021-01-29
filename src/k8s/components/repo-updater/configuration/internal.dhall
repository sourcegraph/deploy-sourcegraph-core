let DeploymentConfig = ./internal/deployment.dhall

let ServiceConfig = ./internal/service.dhall

let configuration =
      { Deployment : { repo-updater : DeploymentConfig }
      , Service : { repo-updater : ServiceConfig }
      }

in  configuration
