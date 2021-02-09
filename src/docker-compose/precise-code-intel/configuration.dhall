let util = ../../util/package.dhall

let Simple/PreciseCodeIntel =
      ( ../../simple/precise-code-intel/package.dhall
      ).Containers.preciseCodeIntel

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let configuration =
      { Type =
          { image : util.Image.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default.image = Simple/PreciseCodeIntel.image
      , default.healthCheck
        = util.HealthCheck/toDockerCompose Simple/PreciseCodeIntel.Healthcheck
      }

in  { configuration }
