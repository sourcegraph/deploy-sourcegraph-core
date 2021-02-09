let Kubernetes/VolumeMount =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let shared = ./shared.dhall

in  shared ⩓ { volumeMounts : Optional (List Kubernetes/VolumeMount.Type) }
