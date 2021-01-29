let Kubernetes/Probe = ../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/VolumeMount =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ObjectMeta =
      ../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/DeploymentSpec =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentSpec.dhall

let Kubernetes/LabelSelector =
      ../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/DeploymentStrategy =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentStrategy.dhall

let Kubernetes/RollingUpdateDeployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.RollingUpdateDeployment.dhall

let Kubernetes/IntOrString =
      ../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let Kubernetes/PodTemplateSpec =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/Container =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/PodSpec =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/ResourceRequirements =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/Volume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/EmptyDirVolumeSource =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.EmptyDirVolumeSource.dhall

let Configuration/global = ../../configuration/global.dhall

let Configuration/Internal = ./configuration/internal.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let environment/toList = ./configuration/environment/toList.dhall

let Simple/Frontend = ../../../simple/frontend/package.dhall

let util = ../../../util/package.dhall

let Jaeger/generate = ../shared/jaeger/generate.dhall

let Jaeger/defaults = ../shared/jaeger/defaults.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../util/container-resources/toK8s.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "frontend" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "sourcegraph-frontend" }

let Deployment/generate
    : ∀(c : Configuration/Internal) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal) →
        let config = c.Deployment

        let simple/frontend = Simple/Frontend.Containers.frontend

        let simple/internal = Simple/Frontend.Containers.frontendInternal

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let environment =
              environment/toList config.Containers.frontend.Environment

        let image = util.Image/show config.Containers.frontend.image

        let livenessProbe = util.HealthCheck/tok8s simple/frontend.HealthCheck

        let readinessProbe
            : Kubernetes/Probe.Type
            = livenessProbe
              with initialDelaySeconds = None Natural

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/frontend.ports.http
              , name = Some "http"
              }

        let internalPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/internal.ports.http-internal
              , name = Some "http-internal"
              }

        let cacheVolume =
              Kubernetes/VolumeMount::{
              , mountPath = simple/frontend.volumes.CACHE_DIR
              , name = "cache-ssd"
              }

        let k8s/jaegerResource =
              Configuration/ResourceRequirements/toK8s Jaeger/defaults.Resources

        let jaegerConfig =
              c.Deployment.Containers.jaeger
              with resources = k8s/jaegerResource

        let securityContext = config.Containers.frontend.securityContext

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Serves the frontend of Sourcegraph via HTTP(S)."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some "sourcegraph-frontend"
                , namespace = c.namespace
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes/RollingUpdateDeployment::{
                    , maxSurge = Some (Kubernetes/IntOrString.Int 2)
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
                        , args = Some [ "serve" ]
                        , env = Some environment
                        , image = Some image
                        , livenessProbe = Some livenessProbe
                        , name = "frontend"
                        , ports = Some [ httpPort, internalPort ]
                        , readinessProbe = Some readinessProbe
                        , resources = Some Kubernetes/ResourceRequirements::{
                          , limits = Some
                            [ { mapKey = "cpu", mapValue = "2" }
                            , { mapKey = "memory", mapValue = "4G" }
                            ]
                          , requests = Some
                            [ { mapKey = "cpu", mapValue = "2" }
                            , { mapKey = "memory", mapValue = "2G" }
                            ]
                          }
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , securityContext
                        , volumeMounts = Some [ cacheVolume ]
                        }
                      , Jaeger/generate jaegerConfig
                      ]
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    , serviceAccountName = Some "sourcegraph-frontend"
                    , volumes = Some
                      [ Kubernetes/Volume::{
                        , emptyDir = Some Kubernetes/EmptyDirVolumeSource::{=}
                        , name = "cache-ssd"
                        }
                      ]
                    }
                  }
                }
              }

        in  deployment

let generate =
      λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Deployment/generate config

        in  { Deployment.sourcegraph-frontend = deployment }

in  generate
