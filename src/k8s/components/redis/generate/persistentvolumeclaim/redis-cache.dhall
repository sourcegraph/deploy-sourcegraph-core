let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/PersistentVolumeClaimSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Configuration/Internal/PersistentVolumeClaim =
      ../../configuration/internal/persistentvolumeclaim.dhall

let PersistentVolumeClaim/generate
    : ∀(c : Configuration/Internal/PersistentVolumeClaim) →
        Kubernetes/PersistentVolumeClaim.Type
    = λ(c : Configuration/Internal/PersistentVolumeClaim) →
        Kubernetes/PersistentVolumeClaim::{
        , metadata = Kubernetes/ObjectMeta::{ name = Some "redis-cache" }
        , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
          , accessModes = Some [ "ReadWriteOnce" ]
          , storageClassName = c.storageClassName
          , resources = Some Kubernetes/ResourceRequirements::{
            , requests = Some
              [ { mapKey = "storage", mapValue = c.volumeSize } ]
            }
          }
        }

in  PersistentVolumeClaim/generate
