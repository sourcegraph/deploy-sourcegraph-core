let Kubernetes/Deployment =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/DeploymentSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentSpec.dhall

let Kubernetes/LabelSelector =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/DeploymentStrategy =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentStrategy.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/PodSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Simple = ../../../../../simple/jaeger/package.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Container/jaeger/generate = ../container/jaeger.dhall

let Fixtures/deployment = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Util/listToOptional = ../../../../util/functions/list-to-optional.dhall

let Pod/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/PodSpec.Type
    = λ(c : Configuration/Internal/Deployment) →
        let volumes =
              Util/listToOptional Kubernetes/Volume.Type c.additionalVolumes

        in  Kubernetes/PodSpec::{
            , containers =
                [ Container/jaeger/generate c.Containers.jaeger ] # c.sideCars
            , securityContext = Some Kubernetes/PodSecurityContext::{
              , runAsUser = Some 0
              }
            , volumes
            }

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let simple = Simple.Containers.jaeger

        let name = simple.name

        let namespace = c.namespace

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , labels = Some
                  [ { mapKey = "app", mapValue = name }
                  , { mapKey = "app.kubernetes.io/component", mapValue = name }
                  , { mapKey = "app.kubernetes.io/name", mapValue = name }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some name
                , namespace
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , replicas = Some 1
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = name }
                    , { mapKey = "app.kubernetes.io/component"
                      , mapValue = "all-in-one"
                      }
                    , { mapKey = "app.kubernetes.io/name", mapValue = name }
                    ]
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , type = Some "Recreate"
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , annotations = Some
                      [ { mapKey = "prometheus.io/port", mapValue = "16686" }
                      , { mapKey = "prometheus.io/scrape", mapValue = "true" }
                      ]
                    , labels = Some
                      [ { mapKey = "app", mapValue = name }
                      , { mapKey = "app.kubernetes.io/component"
                        , mapValue = "all-in-one"
                        }
                      , { mapKey = "app.kubernetes.io/name", mapValue = name }
                      , { mapKey = "deploy", mapValue = "sourcegraph" }
                      ]
                    }
                  , spec = Some (Pod/generate c)
                  }
                }
              }

        in  deployment

let tc = Fixtures/deployment.jaeger.Config

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

let Test/sidecars/empty =
        assert
      :   ( Pod/generate
              (tc with sideCars = ([] : List Kubernetes/Container.Type))
          ).containers
        ≡ [ Container/jaeger/generate tc.Containers.jaeger ]

let Test/sidecars/nonEmpty =
        assert
      :   ( Pod/generate (tc with sideCars = [ Fixtures/global.SideCars.Foo ])
          ).containers
        ≡   [ Container/jaeger/generate tc.Containers.jaeger ]
          # [ Fixtures/global.SideCars.Foo ]

let Test/volumes/nonEmpty =
        assert
      :   ( Pod/generate
              (tc with additionalVolumes = [ Fixtures/global.Volumes.NFS ])
          ).volumes
        ≡ Some [ Fixtures/global.Volumes.NFS ]

let Test/volumes/empty =
        assert
      :   ( Pod/generate
              (tc with additionalVolumes = [ Fixtures/global.Volumes.NFS ])
          ).volumes
        ≡ Some [ Fixtures/global.Volumes.NFS ]

in  Deployment/generate
