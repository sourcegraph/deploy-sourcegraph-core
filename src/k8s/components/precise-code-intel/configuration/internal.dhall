let DeploymentConfig = ./internal/deployment.dhall

let ServiceConfig = ./internal/service.dhall

let configuration =
      { Deployment : { precise-code-intel-worker : DeploymentConfig }
      , Service : { precise-code-intel-worker : ServiceConfig }
      }

in  configuration
