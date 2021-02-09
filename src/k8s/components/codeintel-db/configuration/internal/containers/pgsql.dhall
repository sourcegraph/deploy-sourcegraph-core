let Kubernetes/EnvVar =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let shared = ./shared.dhall

in    shared
    ⩓ { envVars : Optional (List Kubernetes/EnvVar.Type)
      , volumeMounts : Optional (List Kubernetes/VolumeMount.Type)
      }
