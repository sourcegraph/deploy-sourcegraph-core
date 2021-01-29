let Kubernetes/PersistentVolumeSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeSpec.dhall

let config = { spec : Optional Kubernetes/PersistentVolumeSpec.Type }

in  config
