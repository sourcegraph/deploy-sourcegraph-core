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

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Jaeger/generate = ../../shared/jaeger/generate.dhall

let Simple = ../../../../simple/github-proxy/package.dhall

let util = ../../../../util/package.dhall

let Configuration/Internal/Deployment =
      ../configuration/internal/deployment.dhall

let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/ResourceRequirements =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "github-proxy" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let container = c.Containers.github-proxy

        let simple = Simple.Containers.github-proxy

        let environment = container.envVars

        let namespace = c.namespace

        let name = simple.name

        let image = util.Image/show container.image

        let securityContext = container.securityContext

        let resources = container.resources

        let appLabel = { app = simple.name }

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple.ports.http
              , name = Some "http"
              }

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Rate-limiting proxy for the GitHub API."
                        }
                    )
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
                            , image = Some image
                            , name
                            , env = environment
                            , volumeMounts = container.volumeMounts
                            , ports = Some [ httpPort ]
                            , resources
                            , securityContext
                            , terminationMessagePolicy = Some
                                "FallbackToLogsOnError"
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

let exampleImage =
      util.Image::{
      , name = "sourcegraph/github-proxy"
      , registry = Some "index.docker.io"
      , digest = Some "abc123DEADBEEF"
      , tag = "test"
      }

let exampleEnvironment =
      Some
        [ Kubernetes/EnvVar::{ name = "LOG_REQUESTS", value = Some "false" } ]

let sharedExample =
      { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = exampleImage
      }

let exampleConfig
    : Configuration/Internal/Deployment
    = { namespace = None Text
      , Containers =
        { github-proxy =
              sharedExample
            ∧ { envVars = exampleEnvironment
              , volumeMounts = Some ([] : List Kubernetes/VolumeMount.Type)
              }
        , jaeger = sharedExample
        }
      , sideCars = [] : List Kubernetes/Container.Type
      }

let example0 =
        assert
      : (Deployment/generate exampleConfig).metadata.namespace ≡ None Text

let example1 =
        assert
      :   ( Deployment/generate (exampleConfig with namespace = Some "qwerty")
          ).metadata.namespace
        ≡ Some "qwerty"

in  Deployment/generate
