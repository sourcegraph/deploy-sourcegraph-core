let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/internal/service = ../../configuration/internal/service.dhall

let Generate
    : ∀(c : Configuration/internal/service) → Kubernetes/Service.Type
    = λ(c : Configuration/internal/service) →
        let namespace = c.namespace

        in  Kubernetes/Service::{
            , metadata = Kubernetes/ObjectMeta::{
              , labels = Some
                [ { mapKey = "app", mapValue = "jaeger" }
                , { mapKey = "app.kubernetes.io/component"
                  , mapValue = "jaeger"
                  }
                , { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
                , { mapKey = "deploy", mapValue = "sourcegraph" }
                , { mapKey = "sourcegraph-resource-requires"
                  , mapValue = "no-cluster-admin"
                  }
                ]
              , name = Some "jaeger-query"
              , namespace
              }
            , spec = Some Kubernetes/ServiceSpec::{
              , ports = Some
                [ Kubernetes/ServicePort::{
                  , name = Some "query-http"
                  , port = 16686
                  , protocol = Some "TCP"
                  , targetPort = Some
                      (< Int : Natural | String : Text >.Int 16686)
                  }
                ]
              , selector = Some
                [ { mapKey = "app.kubernetes.io/component"
                  , mapValue = "all-in-one"
                  }
                , { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
                ]
              , type = Some "ClusterIP"
              }
            }

in  Generate
