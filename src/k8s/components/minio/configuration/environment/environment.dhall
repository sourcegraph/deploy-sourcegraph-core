let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Simple/Minio/Environment =
      (../../../../../simple/minio/package.dhall).Containers.minio.environment

let environment =
      { Type =
          { MINIO_ACCESS_KEY : Kubernetes/EnvVar.Type
          , MINIO_SECRET_KEY : Kubernetes/EnvVar.Type
          }
      , default =
        { MINIO_ACCESS_KEY = Kubernetes/EnvVar::{
          , name = Simple/Minio/Environment.MINIO_ACCESS_KEY.name
          , value = Some "${Simple/Minio/Environment.MINIO_ACCESS_KEY.value}"
          }
        , MINIO_SECRET_KEY = Kubernetes/EnvVar::{
          , name = Simple/Minio/Environment.MINIO_SECRET_KEY.name
          , value = Some "${Simple/Minio/Environment.MINIO_SECRET_KEY.value}"
          }
        }
      }

in  environment
