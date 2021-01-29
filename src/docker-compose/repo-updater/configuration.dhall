let util = ../../util/package.dhall

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let Simple/RepoUpdater =
      (../../simple/repo-updater/package.dhall).Containers.repo-updater

let environment = (./environment.dhall).environment

let configuration =
      { Type =
          { image : util.Image.Type
          , environment : environment.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default =
        { environment = environment.default
        , image = Simple/RepoUpdater.image
        , healthcheck =
            util.HealthCheck/toDockerCompose Simple/RepoUpdater.HealthCheck
        }
      }

in  { configuration }
