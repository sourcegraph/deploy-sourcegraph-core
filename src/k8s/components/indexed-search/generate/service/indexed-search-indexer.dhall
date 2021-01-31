let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/Internal/Service =
      ../../configuration/internal/service/indexed-search-indexer.dhall

let Fixtures = ./fixtures.dhall

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
                  [ { mapKey = "description"
                    , mapValue =
                        "Headless service that provides a stable network identity for the indexed-search stateful set."
                    }
                  , { mapKey = "prometheus.io/port", mapValue = "6072" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                  [ { mapKey = "app", mapValue = "indexed-search-indexer" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "indexed-search"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "indexed-search-indexer"
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , clusterIP = Some "None"
                , ports = Some
                  [ Kubernetes/ServicePort::{

                    , port = 6072
                    , targetPort = Some
                        (< Int : Natural | String : Text >.Int 6072)
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "indexed-search" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let tc = Fixtures.indexed-search.ConfigIndexedSearchIndexer

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
