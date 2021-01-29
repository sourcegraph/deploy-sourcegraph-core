let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ConfigMap =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let Configuration/Internal/ConfigMap = ../configuration/internal/configmap.dhall

let Service/generate
    : ∀(c : Configuration/Internal/ConfigMap) → Kubernetes/ConfigMap.Type
    = λ(c : Configuration/Internal/ConfigMap) →
        let namespace = c.namespace

        in  Kubernetes/ConfigMap::{
            , metadata = Kubernetes/ObjectMeta::{
              , namespace
              , labels = Some
                [ { mapKey = "app.kubernetes.io/component"
                  , mapValue = "grafana"
                  }
                , { mapKey = "deploy", mapValue = "sourcegraph" }
                , { mapKey = "sourcegraph-resource-requires"
                  , mapValue = "no-cluster-admin"
                  }
                ]
              , name = Some "grafana"
              }
            , data = Some
              [ { mapKey = "datasources.yml", mapValue = c.datasources } ]
            }

in  Service/generate
