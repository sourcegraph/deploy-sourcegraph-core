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

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Jaeger/generate = ../../../shared/jaeger/generate.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "frontend" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "sourcegraph-frontend" }

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Container/frontend/generate = ../container/frontend.dhall

let Fixtures/deployment = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Util/ListToOptional = ../../../../util/functions/list-to-optional.dhall

let tc = Fixtures/deployment.frontend.Config

let PodSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let volumes = Util/ListToOptional Kubernetes/Volume.Type c.volumes

        in  Kubernetes/PodSpec::{
            , containers =
                  [ Container/frontend/generate c.Containers.frontend
                  , Jaeger/generate c.Containers.jaeger
                  ]
                # c.sideCars
            , securityContext = Some Kubernetes/PodSecurityContext::{
              , runAsUser = Some 0
              }
            , volumes
            }

let Test/volumes/none =
        assert
      :   (PodSpec/generate tc).volumes
        ≡ Fixtures/deployment.frontend.Volumes.emptyExpected

let Test/volumes/some =
        assert
      :   ( PodSpec/generate
              (tc with volumes = Fixtures/deployment.frontend.Volumes.input)
          ).volumes
        ≡ Fixtures/deployment.frontend.Volumes.expected

let test/baseContainers =
      [ Container/frontend/generate tc.Containers.frontend
      , Jaeger/generate tc.Containers.jaeger
      ]

let Test/sideCars/none =
        assert
      :   (PodSpec/generate tc).containers
        ≡   test/baseContainers
          # Fixtures/deployment.frontend.SideCars.emptyExpected

let Test/sideCars/some =
        assert
      :   ( PodSpec/generate
              (tc with sideCars = Fixtures/deployment.frontend.SideCars.input)
          ).containers
        ≡ test/baseContainers # Fixtures/deployment.frontend.SideCars.expected

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
                    ( toMap
                        { description =
                            "Serves the frontend of Sourcegraph via HTTP(S)."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some "sourcegraph-frontend"
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
