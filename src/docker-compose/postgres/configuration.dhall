let util = ../../util/package.dhall

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let Simple/Postgres = (../../simple/postgres/package.dhall).Containers.pgsql

let configuration =
      { Type =
          { image : util.Image.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default =
        { image = Simple/Postgres.image
        , healthcheck =
            util.HealthCheck/toDockerCompose Simple/Postgres.HealthCheck
        }
      }

in  { configuration }
