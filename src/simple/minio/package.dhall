let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/minio

let ports = { minio = { number = 9000, name = Some "minio" } }

let healthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/minio/health/live"
        , port = ports.minio
        , scheme = util.HealthCheck/Scheme.HTTP
        , initialDelaySeconds = Some 60
        , timeoutSeconds = Some 5
        , intervalSeconds = Some 5
        }

let volumes = { minio-data = "/data" }

let environment =
      { MINIO_ACCESS_KEY =
        { name = "MINIO_ACCESS_KEY", value = "AKIAIOSFODNN7EXAMPLE" }
      , MINIO_SECRET_KEY =
        { name = "MINIO_SECRET_KEY"
        , value = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
        }
      }

let minioContainer =
        Container::{ image }
      ∧ { name = "minio"
        , environment
        , ports
        , HealthCheck = healthCheck
        , volumes
        }

let Containers = { minio = minioContainer }

in  { Containers }
