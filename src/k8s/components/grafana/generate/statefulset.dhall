let Kubernetes/StatefulSet =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/StatefulSetSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetSpec.dhall

let Kubernetes/ResourceRequirements =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/Volume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/PersistentVolumeClaimSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/LabelSelector =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/PodSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/ConfigMapVolumeSource =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMapVolumeSource.dhall

let Kubernetes/StatefulSetUpdateStrategy =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetUpdateStrategy.dhall

let util = ../../../../util/package.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "grafana" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "grafana" }

let config = ../configuration/internal/statefulset.dhall

let simple/grafana =
      (../../../../simple/grafana/package.dhall).Containers.grafana

let generate
    : ∀(c : config) → Kubernetes/StatefulSet.Type
    = λ(c : config) →
        let grafanaContainer =
              Kubernetes/Container::{
              , image = Some (util.Image/show c.image)
              , env = c.envVars
              , name = "grafana"
              , ports = Some
                [ Kubernetes/ContainerPort::{
                  , containerPort = simple/grafana.ports.httpPort
                  , name = Some "http"
                  }
                ]
              , resources = c.containerResources
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , volumeMounts = c.volumeMounts
              }

        let statefulSet =
              Kubernetes/StatefulSet::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Metrics/monitoring dashboards and alerts."
                        }
                    )
                , labels = Some
                    ( toMap
                        (   deploySourcegraphLabel
                          ∧ componentLabel
                          ∧ noClusterAdminLabel
                        )
                    )
                , name = Some "grafana"
                , namespace = c.namespace
                }
              , spec = Some Kubernetes/StatefulSetSpec::{
                , updateStrategy = Some Kubernetes/StatefulSetUpdateStrategy::{
                  , type = Some "RollingUpdate"
                  }
                , replicas = Some 1
                , serviceName = "grafana"
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some (toMap (appLabel ∧ deploySourcegraphLabel))
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers = [ grafanaContainer ] # c.sideCars
                    , securityContext = c.podSecurityContext
                    , serviceAccountName = Some "grafana"
                    , volumes = Some
                      [ Kubernetes/Volume::{
                        , name = "config"
                        , configMap = Some Kubernetes/ConfigMapVolumeSource::{
                          , name = Some "grafana"
                          , defaultMode = Some 511
                          }
                        }
                      ]
                    }
                  }
                , volumeClaimTemplates = Some
                  [ Kubernetes/PersistentVolumeClaim::{
                    , metadata = Kubernetes/ObjectMeta::{
                      , name = Some "grafana-data"
                      }
                    , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
                      , accessModes = Some [ "ReadWriteOnce" ]
                      , storageClassName = c.storageClassName
                      , resources = Some Kubernetes/ResourceRequirements::{
                        , requests = Some
                          [ { mapKey = "storage", mapValue = c.dataVolumeSize }
                          ]
                        }
                      }
                    }
                  ]
                }
              }

        in  statefulSet

in  generate
