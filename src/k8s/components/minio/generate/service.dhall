let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/Internal/Service = ../configuration/internal/service.dhall

let Simple = ../../../../simple/minio/package.dhall

let Service/generate
    : ∀(c : Configuration/Internal/Service) → Kubernetes/Service.Type
    = λ(c : Configuration/Internal/Service) →
        let simple = Simple.Containers.minio

        let name = simple.name

        let namespace = c.namespace

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , annotations = Some
                  [ { mapKey = "prometheus.io/path"
                    , mapValue = "/minio/prometheus/metrics"
                    }
                  , { mapKey = "prometheus.io/port", mapValue = "9000" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                  [ { mapKey = "app", mapValue = name }
                  , { mapKey = "app.kubernetes.io/component", mapValue = name }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some name
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "minio"
                    , port = 9000
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "minio")
                    }
                  ]
                , selector = Some [ { mapKey = "app", mapValue = name } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

in  Service/generate
