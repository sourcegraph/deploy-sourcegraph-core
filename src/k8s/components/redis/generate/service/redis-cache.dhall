let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/Internal/Service = ../../configuration/internal/service.dhall

let Fixtures/redis/service = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Service/generate
    : ∀(c : Configuration/Internal/Service) → Kubernetes/Service.Type
    = λ(c : Configuration/Internal/Service) →
        let namespace = c.namespace

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , annotations = Some
                  [ { mapKey = "prometheus.io/port", mapValue = "9121" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                  [ { mapKey = "app", mapValue = "redis-cache" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "redis"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "redis-cache"
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "redis"
                    , port = 6379
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "redis")
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "redis-cache" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let tc = Fixtures/redis/service.redis.Config/RedisCache

let Test/namespace/none =
        assert
      :   (Service/generate (tc with namespace = None Text)).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( Service/generate
              (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  Service/generate
