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

let Simple = ../../../../../simple/query-runner/package.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let Container/query-runner/generate = ../containers/query-runner.dhall

let Fixtures/deployment = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let simple = Simple.Containers.query-runner

        let namespace = c.namespace

        let name = simple.name

        let componentLabel = { `app.kubernetes.io/component` = simple.name }

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let appLabel = { app = simple.name }

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Saved search query runner / notification service."
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
                          [ Container/query-runner/generate
                              c.Containers.query-runner
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

let tc = Fixtures/deployment.query-runner.Config

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
