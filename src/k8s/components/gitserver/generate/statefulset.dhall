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

let Kubernetes/StatefulSetUpdateStrategy =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetUpdateStrategy.dhall

let util = ../../../../util/package.dhall

let Jaeger/generate = ../../shared/jaeger/generate.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "gitserver" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "gitserver" }

let groupLabels =
      [ { mapKey = "group", mapValue = "backend" }
      , { mapKey = "type", mapValue = "gitserver" }
      ]

let config = ../configuration/internal/statefulset.dhall

let generate
    : ∀(c : config) → Kubernetes/StatefulSet.Type
    = λ(c : config) →
        let labels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let image = util.Image/show c.Containers.gitserver.image

        let livenessProbe = c.Containers.gitserver.healthcheck

        let rpcPort =
              Kubernetes/ContainerPort::{
              , containerPort = c.Containers.gitserver.rpc/port
              , name = Some "rpc"
              }

        let securityContext = c.Containers.gitserver.securityContext

        let gitserverContainer =
              Kubernetes/Container::{
              , args = Some [ "run" ]
              , env = c.Containers.gitserver.envVars
              , image = Some image
              , livenessProbe = Some livenessProbe
              , name = "gitserver"
              , ports = Some [ rpcPort ]
              , resources = c.Containers.gitserver.containerResources
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              , securityContext
              , volumeMounts = c.Containers.gitserver.volumeMounts
              }

        let jaegerContainer = Jaeger/generate c.Containers.jaeger

        let containers = [ gitserverContainer, jaegerContainer ] # c.sideCars

        let statefulSet =
              Kubernetes/StatefulSet::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Stores clones of repositories to perform Git operations."
                        }
                    )
                , labels = Some labels
                , name = Some "gitserver"
                , namespace = c.namespace
                }
              , spec = Some Kubernetes/StatefulSetSpec::{
                , updateStrategy = Some Kubernetes/StatefulSetUpdateStrategy::{
                  , type = Some "RollingUpdate"
                  }
                , replicas = Some c.replicas
                , serviceName = "gitserver"
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some
                        (   toMap (appLabel ∧ deploySourcegraphLabel)
                          # groupLabels
                        )
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers
                    , securityContext = c.podSecurityContext
                    , volumes = Some [ Kubernetes/Volume::{ name = "repos" } ]
                    }
                  }
                , volumeClaimTemplates = Some
                  [ Kubernetes/PersistentVolumeClaim::{
                    , metadata = Kubernetes/ObjectMeta::{ name = Some "repos" }
                    , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
                      , accessModes = Some [ "ReadWriteOnce" ]
                      , storageClassName = c.storageClassName
                      , resources = Some Kubernetes/ResourceRequirements::{
                        , requests = Some
                          [ { mapKey = "storage", mapValue = c.reposVolumeSize }
                          ]
                        }
                      }
                    }
                  ]
                }
              }

        in  statefulSet

in  generate
