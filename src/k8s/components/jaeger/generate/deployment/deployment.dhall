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

let Kubernetes/PodSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Simple = ../../../../../simple/jaeger/package.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Container/jaeger/generate = ../container/jaeger.dhall

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
                  , spec = Some Kubernetes/PodSpec::{
                    , containers =
                          [ Container/jaeger/generate c.Containers.jaeger ]
                        # c.sideCars
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    }
                  }
                }
              }

        in  deployment

in  Deployment/generate
