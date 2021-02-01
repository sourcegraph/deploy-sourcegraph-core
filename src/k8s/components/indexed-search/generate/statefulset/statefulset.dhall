let Kubernetes/StatefulSet =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/PersistentVolumeClaimSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/StatefulSetSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetSpec.dhall

let Kubernetes/LabelSelector =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/StatefulSetUpdateStrategy =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetUpdateStrategy.dhall

let Kubernetes/PodSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "indexed-search" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "indexed-search" }

let Configuration/Internal/StatefulSet =
      ../../configuration/internal/statefulset.dhall

let Container/zoekt-indexserver/generate = ../container/zoekt-indexserver.dhall

let Container/zoekt-webserver/generate = ../container/zoekt-webserver.dhall

let Fixtures/statefulset = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let tc = Fixtures/statefulset.indexed-search.Config

let Util/ListToOptional = ../../../../util/functions/list-to-optional.dhall

let PodSpec/generate
    : ∀(c : Configuration/Internal/StatefulSet) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/StatefulSet) →
        let volumes =
              Util/ListToOptional
                Kubernetes/Volume.Type
                [ Kubernetes/Volume::{ name = "data" } ]

        in  Kubernetes/PodSpec::{
            , containers =
                  [ Container/zoekt-webserver/generate
                      c.Containers.zoekt-webserver
                  , Container/zoekt-indexserver/generate
                      c.Containers.zoekt-indexserver
                  ]
                # c.sideCars
            , securityContext = Some Kubernetes/PodSecurityContext::{
              , runAsUser = Some 0
              }
            , volumes
            }

let DataVolume/generate
    : ∀(c : Configuration/Internal/StatefulSet) →
        Kubernetes/PersistentVolumeClaim.Type
    = λ(c : Configuration/Internal/StatefulSet) →
        let size = c.dataVolumeSize

        let resources =
              Kubernetes/ResourceRequirements::{
              , requests = Some (toMap { storage = size })
              }

        let storageClassName = c.storageClassName

        in  Kubernetes/PersistentVolumeClaim::{
            , metadata = Kubernetes/ObjectMeta::{
              , labels = Some (toMap deploySourcegraphLabel)
              , name = Some "data"
              }
            , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
              , accessModes = Some [ "ReadWriteOnce" ]
              , resources = Some resources
              , storageClassName
              }
            }

let StatefulSetSpec/generate
    : ∀(c : Configuration/Internal/StatefulSet) →
        Kubernetes/StatefulSetSpec.Type
    = λ(c : Configuration/Internal/StatefulSet) →
        let replicas = c.replicas

        let volumeClaimTemplates = [ DataVolume/generate c ]

        in  Kubernetes/StatefulSetSpec::{
            , serviceName = "indexed-search"
            , replicas = Some replicas
            , revisionHistoryLimit = Some 10
            , selector = Kubernetes/LabelSelector::{
              , matchLabels = Some (toMap appLabel)
              }
            , updateStrategy = Some Kubernetes/StatefulSetUpdateStrategy::{
              , type = Some "RollingUpdate"
              }
            , template = Kubernetes/PodTemplateSpec::{
              , metadata = Kubernetes/ObjectMeta::{
                , labels = Some (toMap (appLabel ∧ deploySourcegraphLabel))
                }
              , spec = Some (PodSpec/generate c)
              }
            , volumeClaimTemplates = Some volumeClaimTemplates
            }

let Test/replicas =
        assert
      :   ( StatefulSetSpec/generate
              (tc with replicas = Fixtures/global.Replicas)
          ).replicas
        ≡ Some Fixtures/global.Replicas

let StatefulSet/generate
    : ∀(c : Configuration/Internal/StatefulSet) → Kubernetes/StatefulSet.Type
    = λ(c : Configuration/Internal/StatefulSet) →
        let namespace = c.namespace

        let labels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let statefulset =
              Kubernetes/StatefulSet::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Backend for indexed text search operations."
                        }
                    )
                , labels = Some labels
                , name = Some "indexed-search"
                , namespace
                }
              , spec = Some (StatefulSetSpec/generate c)
              }

        in  statefulset

let Test/namespace/none =
        assert
      :   ( StatefulSet/generate (tc with namespace = None Text)
          ).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( StatefulSet/generate
              (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

let Test/volume =
        assert
      :   DataVolume/generate
            ( tc
              with storageClassName = Some
                  Fixtures/statefulset.Volume.StorageClassName
              with dataVolumeSize = Fixtures/statefulset.Volume.Size
            )
        ≡ Fixtures/statefulset.Volume.Expected

in  StatefulSet/generate
