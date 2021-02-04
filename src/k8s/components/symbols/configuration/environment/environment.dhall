let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/ObjectFieldSelector =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let Simple/Symbols = ../../../../../simple/symbols/package.dhall

let Simple/Symbols/Environment = Simple/Symbols.Containers.symbols.environment

let environment =
      { Type =
          { CACHE_DIR : Kubernetes/EnvVar.Type
          , POD_NAME : Kubernetes/EnvVar.Type
          , SYMBOLS_CACHE_SIZE_MB : Kubernetes/EnvVar.Type
          }
      , default =
        { CACHE_DIR = Kubernetes/EnvVar::{
          , name = "CACHE_DIR"
          , value = Some
              "${Simple/Symbols/Environment.CACHE_DIR.value}/\$(POD_NAME)"
          }
        , POD_NAME = Kubernetes/EnvVar::{
          , name = "POD_NAME"
          , valueFrom = Some Kubernetes/EnvVarSource::{
            , fieldRef = Some Kubernetes/ObjectFieldSelector::{
              , fieldPath = "metadata.name"
              }
            }
          }
        , SYMBOLS_CACHE_SIZE_MB = Kubernetes/EnvVar::{
          , name = "SYMBOLS_CACHE_SIZE_MB"
          , value = Some "100000"
          }
        }
      }

in  environment
