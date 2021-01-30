let Kubernetes/Deployment =
      ../../../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

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
              , metadata = schemas.ObjectMeta::{
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
              , spec = Some schemas.DeploymentSpec::{
                , replicas = Some 1
                , selector = schemas.LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = name }
                    , { mapKey = "app.kubernetes.io/component"
                      , mapValue = "all-in-one"
                      }
                    , { mapKey = "app.kubernetes.io/name", mapValue = name }
                    ]
                  }
                , strategy = Some schemas.DeploymentStrategy::{
                  , type = Some "Recreate"
                  }
                , template = schemas.PodTemplateSpec::{
                  , metadata = schemas.ObjectMeta::{
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
                  , spec = Some schemas.PodSpec::{
                    , containers =
                        [ Container/jaeger/generate c.Containers ] # c.sideCars
                    , securityContext = Some schemas.PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    }
                  }
                }
              }

        in  deployment

in  Deployment/generate
