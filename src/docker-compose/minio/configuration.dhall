let util = ../../util/package.dhall

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let Simple/Minio = (../../simple/minio/package.dhall).Containers.minio

let configuration =
      { Type =
          { image : util.Image.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default =
        { image = Simple/Minio.image
        , healthcheck =
            util.HealthCheck/toDockerCompose Simple/Minio.HealthCheck
        }
      }

in  { configuration }
