let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let environment =
      { Type = { SOURCEGRAPHDOTCOM_MODE : Kubernetes/EnvVar.Type }
      , default.SOURCEGRAPHDOTCOM_MODE
        = Kubernetes/EnvVar::{
        , name = "SOURCEGRAPHDOTCOM_MODE"
        , value = Some "false"
        }
      }

in  environment
