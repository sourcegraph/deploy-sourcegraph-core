let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let environment =
      { Type = { LOG_REQUESTS : Kubernetes/EnvVar.Type }
      , default.LOG_REQUESTS
        = Kubernetes/EnvVar::{ name = "LOG_REQUESTS", value = Some "false" }
      }

in  environment
