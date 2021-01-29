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

let Jaeger/generate = ../../../shared/jaeger/generate.dhall

let volumes/toList = ../../configuration/volumes/toList.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "symbols" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "symbols" }

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Container/symbols/generate = ../container/symbols.dhall

let Fixtures/deployment = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let tc = Fixtures/deployment.symbols.Config

let PodSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let volumes = volumes/toList c.volumes

        in  Kubernetes/PodSpec::{
            , containers =
                  [ Container/symbols/generate c.Containers.symbols
                  , Jaeger/generate c.Containers.jaeger
                  ]
                # c.sideCars
            , securityContext = Some Kubernetes/PodSecurityContext::{
              , runAsUser = Some 0
              }
            , volumes = Some volumes
            }

let Test/volumes =
        assert
      :   (PodSpec/generate tc).volumes
        ≡ Some Fixtures/deployment.symbols.Volumes.expected

let DeploymentSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/DeploymentSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let replicas = c.replicas

        in  Kubernetes/DeploymentSpec::{
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
              , spec = Some (PodSpec/generate c)
              }
            }

let Test/replicas =
        assert
      :   ( DeploymentSpec/generate
              (tc with replicas = Fixtures/global.Replicas)
          ).replicas
        ≡ Some Fixtures/global.Replicas

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
                    (toMap { description = "Backend for symbols operations." })
                , labels = Some deploymentLabels
                , name = Some "symbols"
                , namespace
                }
              , spec = Some (DeploymentSpec/generate c)
              }

        in  deployment

let Test/namespace/none =
        assert
      :   ( Deployment/generate (tc with namespace = None Text)
          ).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( Deployment/generate
              (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  Deployment/generate
