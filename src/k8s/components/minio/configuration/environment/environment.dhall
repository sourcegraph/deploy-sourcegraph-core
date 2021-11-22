let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Simple/Minio/Environment =
      (../../../../../simple/minio/package.dhall).Containers.minio.environment

let environment =
      { Type =
          { MINIO_ROOT_USER : Kubernetes/EnvVar.Type
          , MINIO_ROOT_PASSWORD : Kubernetes/EnvVar.Type
          }
      , default =
        { MINIO_ROOT_USER = Kubernetes/EnvVar::{
          , name = Simple/Minio/Environment.MINIO_ROOT_USER.name
          , value = Some "${Simple/Minio/Environment.MINIO_ROOT_USER.value}"
          }
        , MINIO_ROOT_PASSWORD = Kubernetes/EnvVar::{
          , name = Simple/Minio/Environment.MINIO_ROOT_PASSWORD.name
          , value = Some "${Simple/Minio/Environment.MINIO_ROOT_PASSWORD.value}"
          }
        }
      }

in  environment
