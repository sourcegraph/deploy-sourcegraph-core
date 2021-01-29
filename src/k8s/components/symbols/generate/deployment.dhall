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

let volumes/toList = ../configuration/volumes/toList.dhall

let Simple/Symbols = ../../../../simple/symbols/package.dhall

let util = ../../../../util/package.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "symbols" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "symbols" }

let Configuration/Internal/Deployment =
      ../configuration/internal/deployment.dhall

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let config = c

        let simple/symbols = Simple/Symbols.Containers.symbols

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let volumes = volumes/toList config.volumes

        let image = util.Image/show config.Containers.symbols.image

        let k8sProbe = util.HealthCheck/tok8s simple/symbols.healthCheck

        let probe = k8sProbe with failureThreshold = None Natural

        let livenessProbe = probe with periodSeconds = None Natural

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = None Natural

        let securityContext = config.Containers.symbols.securityContext

        let resources = config.Containers.symbols.resources

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/symbols.ports.http
              , name = Some "http"
              }

        let replicas = config.replicas

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    (toMap { description = "Backend for symbols operations." })
                , labels = Some deploymentLabels
                , name = Some "symbols"
                , namespace = config.namespace
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some replicas
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes/RollingUpdateDeployment::{
                    , maxSurge = Some (Kubernetes/IntOrString.Int 1)
                    , maxUnavailable = Some (Kubernetes/IntOrString.Int 1)
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
                        , image = Some image
                        , livenessProbe = Some livenessProbe
                        , name = "symbols"
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
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    , volumes = Some volumes
                    }
                  }
                }
              }

        in  deployment

in  Deployment/generate
