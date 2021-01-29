let Kubernetes/volume = ../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/EmptyDirVolumeSource =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.EmptyDirVolumeSource.dhall

let cacheSSDVolume =
      Kubernetes/volume::{
      , emptyDir = Some Kubernetes/EmptyDirVolumeSource::{=}
      , name = "cache-ssd"
      }

in  { cacheSSDVolume }
