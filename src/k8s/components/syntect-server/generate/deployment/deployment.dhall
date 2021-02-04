let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

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

let Simple = ../../../../../simple/syntect-server/package.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "syntect-server" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let Container/syntect-server/generate = ../containers/syntect-server.dhall

let Fixtures/deployment = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Util/ListToOptional = ../../../../util/functions/list-to-optional.dhall

let name = Simple.Containers.syntect-server.hostname

let appLabel = { app = name }

let tc = Fixtures/deployment.syntect-server.Config

let PodSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let volumes = Util/ListToOptional Kubernetes/Volume.Type c.volumes

        in  Kubernetes/PodSpec::{
            , containers =
                  [ Container/syntect-server/generate
                      c.Containers.syntect-server
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
        ≡ Fixtures/deployment.syntect-server.Volumes.emptyExpected

let Test/volumes/some =
        assert
      :   ( PodSpec/generate
              ( tc
                with volumes = Fixtures/deployment.syntect-server.Volumes.input
              )
          ).volumes
        ≡ Fixtures/deployment.syntect-server.Volumes.expected

let test/container/syntect =
      Container/syntect-server/generate tc.Containers.syntect-server

let Test/sideCars/none =
        assert
      :   (PodSpec/generate tc).containers
        ≡   [ test/container/syntect ]
          # Fixtures/deployment.syntect-server.Sidecars.emptyExpected

let Test/sideCars/some =
        assert
      :   ( PodSpec/generate
              ( tc
                with sideCars =
                    Fixtures/deployment.syntect-server.Sidecars.input
              )
          ).containers
        ≡   [ test/container/syntect ]
          # Fixtures/deployment.syntect-server.Sidecars.expected

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
            , maxUnavailable = Some (Kubernetes/IntOrString.Int 0)
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
                            "Backend for syntax highlighting operations."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some "syntect-server"
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
