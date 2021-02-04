let DeploymentConfig = ./internal/deployment.dhall

let ServiceConfig = ./internal/service.dhall

let configuration =
      { Deployment : { precise-code-intel : DeploymentConfig }
      , Service : { precise-code-intel : ServiceConfig }
      }

in  configuration
