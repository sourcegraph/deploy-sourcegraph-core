let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServiceAccount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let Configuration/Internal/ServiceAccount =
      ../configuration/internal/serviceaccount.dhall

let ServiceAccount/generate
    : ∀(c : Configuration/Internal/ServiceAccount) →
        Kubernetes/ServiceAccount.Type
    = λ(c : Configuration/Internal/ServiceAccount) →
        let namespace = c.namespace

        let serviceAccount =
              Kubernetes/ServiceAccount::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , labels = Some
                  [ { mapKey = "app.kubernetes.io/component"
                    , mapValue = "grafana"
                    }
                  , { mapKey = "category", mapValue = "rbac" }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "grafana"
                }
              , imagePullSecrets = Some [ { name = Some "docker-registry" } ]
              }

        in  serviceAccount

in  ServiceAccount/generate
