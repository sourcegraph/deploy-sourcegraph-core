let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/PersistentVolumeClaimSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall

let Configuration/Internal/PersistentVolumeClaim =
      ../configuration/internal/persistentVolumeClaim.dhall

let Kubernetes/ResourceRequirements =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let k8s/util = ../../../util/package.dhall

let shared = ./shared.dhall

let PersistentVolumeClaim/generate
    : ∀(c : Configuration/Internal/PersistentVolumeClaim) →
        Kubernetes/PersistentVolumeClaim.Type
    = λ(c : Configuration/Internal/PersistentVolumeClaim) →
        let name = c.name

        let namespace = c.namespace

        let selector = c.selector

        let labels =
              toMap
                (   shared.labels.component
                  ∧ k8s/util.Labels.deploySourcegraph
                  ∧ k8s/util.Labels.noClusterAdmin
                )

        in  Kubernetes/PersistentVolumeClaim::{
            , metadata = Kubernetes/ObjectMeta::{
              , labels = Some labels
              , name = Some name
              , namespace
              }
            , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
              , selector
              , accessModes = Some [ "ReadWriteOnce" ]
              , resources = Some Kubernetes/ResourceRequirements::{
                , requests = Some [ { mapKey = "storage", mapValue = "200Gi" } ]
                }
              , storageClassName = Some "sourcegraph"
              }
            }

in  PersistentVolumeClaim/generate
