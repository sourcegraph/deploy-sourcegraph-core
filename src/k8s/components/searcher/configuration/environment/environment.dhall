let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/ObjectFieldSelector =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let Simple/Searcher = ../../../../../simple/searcher/package.dhall

let Simple/Searcher/Environment =
      Simple/Searcher.Containers.searcher.environment

let environment =
      { Type =
          { SEARCHER_CACHE_SIZE_MB : Kubernetes/EnvVar.Type
          , POD_NAME : Kubernetes/EnvVar.Type
          , CACHE_DIR : Kubernetes/EnvVar.Type
          }
      , default =
        { SEARCHER_CACHE_SIZE_MB = Kubernetes/EnvVar::{
          , name = "SEARCHER_CACHE_SIZE_MB"
          , value = Some "100000"
          }
        , POD_NAME = Kubernetes/EnvVar::{
          , name = "POD_NAME"
          , valueFrom = Some Kubernetes/EnvVarSource::{
            , fieldRef = Some Kubernetes/ObjectFieldSelector::{
              , fieldPath = "metadata.name"
              }
            }
          }
        , CACHE_DIR = Kubernetes/EnvVar::{
          , name = "CACHE_DIR"
          , value = Some
              "${Simple/Searcher/Environment.CACHE_DIR.value}/\$(POD_NAME)"
          }
        }
      }

in  environment
