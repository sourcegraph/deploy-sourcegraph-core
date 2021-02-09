let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/ObjectFieldSelector =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let environment =
      { Type =
          { POD_NAME : Kubernetes/EnvVar.Type
          , NUM_WORKERS : Kubernetes/EnvVar.Type
          }
      , default.NUM_WORKERS
        = Kubernetes/EnvVar::{ name = "NUM_WORKERS", value = Some "4" }
      , default.POD_NAME
        = Kubernetes/EnvVar::{
        , name = "POD_NAME"
        , valueFrom = Some Kubernetes/EnvVarSource::{
          , fieldRef = Some Kubernetes/ObjectFieldSelector::{
            , fieldPath = "metadata.name"
            }
          }
        }
      }

in  environment
