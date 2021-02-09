let Kubernetes/Deployment =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/DeploymentSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentSpec.dhall

let Kubernetes/LabelSelector =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/DeploymentStrategy =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentStrategy.dhall

let Kubernetes/RollingUpdateDeployment =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.RollingUpdateDeployment.dhall

let Kubernetes/IntOrString =
      ../../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/PodSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Container/PreciseCodeIntel/generate = ../containers/precise-code-intel.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "precise-code-intel" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "precise-code-intel-worker" }

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let PodSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let precise-code-intel = c.Containers.precise-code-intel-worker

        in  Kubernetes/PodSpec::{
            , containers =
                  [ Container/PreciseCodeIntel/generate precise-code-intel ]
                # c.sideCars
            , securityContext = Some Kubernetes/PodSecurityContext::{
              , runAsUser = Some 0
              }
            }

let DeploymentSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/DeploymentSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        Kubernetes/DeploymentSpec::{
        , minReadySeconds = Some 10
        , replicas = Some 1
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
          , spec = Some (PodSpec/generate c)
          }
        }

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let namespace = c.namespace

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Handles conversion of uploaded precise code intelligence bundles."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some "precise-code-intel-worker"
                , namespace
                }
              , spec = Some (DeploymentSpec/generate c)
              }

        in  deployment

in  Deployment/generate
