let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/ObjectFieldSelector =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let Simple/Frontend = ../../../../../simple/frontend/package.dhall

let Simple/Frontend/frontend = Simple/Frontend.Containers.frontend

let postgresEnv =
      { Type =
          { PGDATABASE : Kubernetes/EnvVar.Type
          , PGHOST : Kubernetes/EnvVar.Type
          , PGPORT : Kubernetes/EnvVar.Type
          , PGSSLMODE : Kubernetes/EnvVar.Type
          , PGUSER : Kubernetes/EnvVar.Type
          }
      , default =
        { PGDATABASE = Kubernetes/EnvVar::{
          , name = "PGDATABASE"
          , value = Some "sg"
          }
        , PGHOST = Kubernetes/EnvVar::{ name = "PGHOST", value = Some "pgsql" }
        , PGPORT = Kubernetes/EnvVar::{ name = "PGPORT", value = Some "5432" }
        , PGSSLMODE = Kubernetes/EnvVar::{
          , name = "PGSSLMODE"
          , value = Some "disable"
          }
        , PGUSER = Kubernetes/EnvVar::{ name = "PGUSER", value = Some "sg" }
        }
      }

let codeIntelPostgresEnv =
      { Type =
          { CODEINTEL_PGDATABASE : Kubernetes/EnvVar.Type
          , CODEINTEL_PGHOST : Kubernetes/EnvVar.Type
          , CODEINTEL_PGPORT : Kubernetes/EnvVar.Type
          , CODEINTEL_PGSSLMODE : Kubernetes/EnvVar.Type
          , CODEINTEL_PGUSER : Kubernetes/EnvVar.Type
          }
      , default =
        { CODEINTEL_PGDATABASE = Kubernetes/EnvVar::{
          , name = "CODEINTEL_PGDATABASE"
          , value = Some "sg"
          }
        , CODEINTEL_PGHOST = Kubernetes/EnvVar::{
          , name = "CODEINTEL_PGHOST"
          , value = Some "codeintel-db"
          }
        , CODEINTEL_PGPORT = Kubernetes/EnvVar::{
          , name = "CODEINTEL_PGPORT"
          , value = Some "5432"
          }
        , CODEINTEL_PGSSLMODE = Kubernetes/EnvVar::{
          , name = "CODEINTEL_PGSSLMODE"
          , value = Some "disable"
          }
        , CODEINTEL_PGUSER = Kubernetes/EnvVar::{
          , name = "CODEINTEL_PGUSER"
          , value = Some "sg"
          }
        }
      }

let environment =
      { Type =
            { SRC_GIT_SERVERS : Kubernetes/EnvVar.Type
            , POD_NAME : Kubernetes/EnvVar.Type
            , CACHE_DIR : Kubernetes/EnvVar.Type
            , GRAFANA_SERVER_URL : Kubernetes/EnvVar.Type
            , JAEGER_SERVER_URL : Kubernetes/EnvVar.Type
            , PROMETHEUS_URL : Kubernetes/EnvVar.Type
            }
          ⩓ postgresEnv.Type
          ⩓ codeIntelPostgresEnv.Type
      , default =
            { SRC_GIT_SERVERS = Kubernetes/EnvVar::{
              , name = "SRC_GIT_SERVERS"
              , value = Some "gitserver-0.gitserver:3178"
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
                  "${Simple/Frontend/frontend.volumes.CACHE_DIR}/\$(POD_NAME)"
              }
            , GRAFANA_SERVER_URL = Kubernetes/EnvVar::{
              , name = "GRAFANA_SERVER_URL"
              , value = Some "http://grafana:30070"
              }
            , JAEGER_SERVER_URL = Kubernetes/EnvVar::{
              , name = "JAEGER_SERVER_URL"
              , value = Some "http://jaeger-query:16686"
              }
            , PROMETHEUS_URL = Kubernetes/EnvVar::{
              , name = "PROMETHEUS_URL"
              , value = Some "http://prometheus:30090"
              }
            }
          ∧ postgresEnv.default
          ∧ codeIntelPostgresEnv.default
      }

in  environment
