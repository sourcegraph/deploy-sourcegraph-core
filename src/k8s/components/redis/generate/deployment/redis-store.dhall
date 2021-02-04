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

let Kubernetes/PodTemplateSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/PersistentVolumeClaimVolumeSource =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimVolumeSource.dhall

let Kubernetes/PodSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "redis" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "redis-store" }

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment/redis-store.dhall

let Container/redis-store/generate = ../container/redis-store.dhall

let Container/redis-exporter/generate = ../container/redis-exporter.dhall

let Fixtures/deployment = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let tc = Fixtures/deployment.redis.Config/RedisStore

let PodSpec/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let volumes =
              [ Kubernetes/Volume::{
                , name = "redis-data"
                , persistentVolumeClaim = Some Kubernetes/PersistentVolumeClaimVolumeSource::{
                  , claimName = "redis-store"
                  }
                }
              ]

        in  Kubernetes/PodSpec::{
            , containers =
                  [ Container/redis-store/generate c.Containers.redis-store
                  , Container/redis-exporter/generate
                      c.Containers.redis-exporter
                  ]
                # c.sideCars
            , securityContext = Some Kubernetes/PodSecurityContext::{
              , runAsUser = Some 0
              }
            , volumes = Some volumes
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
          , type = Some "Recreate"
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
                            "Redis for storing semi-persistent data like user sessions."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some "redis-store"
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
