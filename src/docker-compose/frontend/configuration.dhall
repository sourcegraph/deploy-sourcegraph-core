let util = ../../util/package.dhall

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let Simple/Frontend = (../../simple/frontend/package.dhall).Containers.frontend

let environment = (./environment.dhall).environment

let configuration =
      { Type =
          { image : util.Image.Type
          , replicas : Natural
          , environment : environment.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default =
        { environment = environment.default
        , image = Simple/Frontend.image
        , replicas = 1
        , healthcheck =
            util.HealthCheck/toDockerCompose Simple/Frontend.HealthCheck
        }
      }

in  { configuration }
