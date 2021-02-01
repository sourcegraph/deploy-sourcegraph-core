let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../container/fixtures.dhall

let Kubernetes/PersistentVolumeClaimSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Configuration/Internal/StatefulSet =
      ../../configuration/internal/statefulset.dhall

let DATA_VOLUME_SIZE = "DATA_VOLUME_SIZE"

let TestConfig
    : Configuration/Internal/StatefulSet
    = { Containers =
        { zoekt-indexserver =
            Fixtures/containers.indexed-search.ConfigIndexServer
        , zoekt-webserver = Fixtures/containers.indexed-search.ConfigWebServer
        }
      , namespace = None Text
      , replicas = 1
      , sideCars = [] : List Kubernetes/Container.Type
      , storageClassName = None Text
      , dataVolumeSize = DATA_VOLUME_SIZE
      }

let TestStorageClassName = "FAKE_NAME_HERE"

let TestSize = "111111111Mi"

let TestVolume =
      Kubernetes/PersistentVolumeClaim::{
      , metadata = Kubernetes/ObjectMeta::{
        , labels = Some (toMap { deploy = "sourcegraph" })
        , name = Some "data"
        }
      , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
        , accessModes = Some [ "ReadWriteOnce" ]
        , resources = Some Kubernetes/ResourceRequirements::{
          , requests = Some [ { mapKey = "storage", mapValue = TestSize } ]
          }
        , storageClassName = Some TestStorageClassName
        }
      }

in  { indexed-search.Config = TestConfig
    , Volume =
      { StorageClassName = TestStorageClassName
      , Size = TestSize
      , Expected = TestVolume
      }
    }
