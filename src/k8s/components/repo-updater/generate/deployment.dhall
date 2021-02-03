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

let Kubernetes/RollingUpdateDeployment =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.RollingUpdateDeployment.dhall

let Kubernetes/IntOrString =
      ../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

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

let Jaeger/generate = ../../shared/jaeger/generate.dhall

let util = ../../../../util/package.dhall

let Configuration/Internal/Deployment =
      ../configuration/internal/deployment.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let name = "repo-updater"

let appLabel = { app = name }

let componentLabel = { `app.kubernetes.io/component` = name }

let Simple/RepoUpdater = ../../../../simple/repo-updater/package.dhall

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let config = c

        let simple/repoUpdater = Simple/RepoUpdater.Containers.repo-updater

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let image = util.Image/show config.Containers.repo-updater.image

        let probe = util.HealthCheck/tok8s simple/repoUpdater.HealthCheck

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with failureThreshold = None Natural
              with initialDelaySeconds = None Natural
              with failureThreshold = Some 3

        let securityContext = config.Containers.repo-updater.securityContext

        let resources = config.Containers.repo-updater.resources

        let port = simple/repoUpdater.ports.http

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = port.number
              , name = port.name
              }

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some name
                , namespace = config.namespace
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , revisionHistoryLimit = Some 10
                , replicas = Some 1
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes/RollingUpdateDeployment::{
                    , maxSurge = Some (Kubernetes/IntOrString.Int 1)
                    , maxUnavailable = Some (Kubernetes/IntOrString.Int 0)
                    }
                  , type = Some "RollingUpdate"
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some (toMap (appLabel ∧ deploySourcegraphLabel))
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers =
                          [ Kubernetes/Container::{
                            , env = config.Containers.repo-updater.envVars
                            , volumeMounts =
                                config.Containers.repo-updater.volumeMounts
                            , image = Some image
                            , name = "repo-updater"
                            , ports = Some
                              [ httpPort
                              , Kubernetes/ContainerPort::{
                                , containerPort = 6060
                                , name = Some "debug"
                                }
                              ]
                            , readinessProbe = Some readinessProbe
                            , resources
                            , terminationMessagePolicy = Some
                                "FallbackToLogsOnError"
                            , securityContext
                            }
                          , Jaeger/generate c.Containers.jaeger
                          ]
                        # c.sideCars
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    }
                  }
                }
              }

        in  deployment

in  Deployment/generate
