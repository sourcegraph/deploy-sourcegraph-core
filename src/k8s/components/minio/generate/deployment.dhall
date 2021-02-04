let Kubernetes/Probe =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/Deployment =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/DeploymentSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentSpec.dhall

let Kubernetes/LabelSelector =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/DeploymentStrategy =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentStrategy.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/PodSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/Volume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/PersistentVolumeClaimVolumeSource =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimVolumeSource.dhall

let Simple = ../../../../simple/minio/package.dhall

let util = ../../../../util/package.dhall

let Configuration/Internal/Deployment =
      ../configuration/internal/deployment.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let internal = c.containers.minio

        let simple = Simple.Containers.minio

        let namespace = c.namespace

        let name = simple.name

        let image = util.Image/show internal.image

        let securityContext = internal.securityContext

        let resources = internal.resources

        let componentLabel = { `app.kubernetes.io/component` = simple.name }

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let appLabel = { app = simple.name }

        let port = simple.ports.minio

        let ports =
              { minio = Kubernetes/ContainerPort::{
                , containerPort = port.number
                , name = port.name
                }
              }

        let probe = util.HealthCheck/tok8s simple.HealthCheck

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = None Natural

        let livenessProbe
            : Kubernetes/Probe.Type
            = probe
              with periodSeconds = None Natural

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    (toMap { description = "MinIO for storing LSIF uploads." })
                , labels = Some deploymentLabels
                , name = Some name
                , namespace
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , type = Some "Recreate"
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some (toMap (appLabel ∧ deploySourcegraphLabel))
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers =
                      [ Kubernetes/Container::{
                        , image = Some image
                        , env = internal.envVars
                        , volumeMounts = internal.volumeMounts
                        , name
                        , ports = Some [ ports.minio ]
                        , livenessProbe = Some livenessProbe
                        , readinessProbe = Some readinessProbe
                        , resources
                        , securityContext
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , args = Some [ "minio", "server", "/data" ]
                        }
                      ]
                    , volumes = Some
                      [ Kubernetes/Volume::{
                        , name = "minio-data"
                        , persistentVolumeClaim = Some Kubernetes/PersistentVolumeClaimVolumeSource::{
                          , claimName = c.volumes.minio-data.claimName
                          }
                        }
                      ]
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    }
                  }
                }
              }

        in  deployment

in  Deployment/generate
