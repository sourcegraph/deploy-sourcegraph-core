let Kubernetes/PersistentVolumeSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeSpec.dhall

let PersistentVolumeGeneratorFunctionType =
      ∀(replicaIndex : Natural) → Kubernetes/PersistentVolumeSpec.Type

in  PersistentVolumeGeneratorFunctionType
