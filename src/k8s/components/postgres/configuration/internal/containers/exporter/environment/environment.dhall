let Kubernetes/EnvVar =
      ../../../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let environment =
      { Type =
          { DATA_SOURCE_NAME : Kubernetes/EnvVar.Type
          , PG_EXPORTER_EXTEND_QUERY_PATH : Kubernetes/EnvVar.Type
          }
      , default =
        { DATA_SOURCE_NAME = Kubernetes/EnvVar::{
          , name = "DATA_SOURCE_NAME"
          , value = Some "postgres://sg:@localhost:5432/?sslmode=disable"
          }
        , PG_EXPORTER_EXTEND_QUERY_PATH = Kubernetes/EnvVar::{
          , name = "PG_EXPORTER_EXTEND_QUERY_PATH"
          , value = Some "/config/queries.yaml"
          }
        }
      }

in  environment
