let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/Internal/Service = ../configuration/internal/service.dhall

let Fixtures/global = ../../../util/test-fixtures/package.dhall

let name = "repo-updater"

let appLabel = { app = name }

let Service/generate
    : ∀(c : Configuration/Internal/Service) → Kubernetes/Service.Type
    = λ(c : Configuration/Internal/Service) →
        let namespace = c.namespace

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , name = Some name
                , annotations = Some
                  [ { mapKey = "prometheus.io/port", mapValue = "6060" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                    ( toMap
                        (   appLabel
                          ∧ { deploy = "sourcegraph"
                            , `app.kubernetes.io/component` = "repo-updater"
                            , sourcegraph-resource-requires = "no-cluster-admin"
                            }
                        )
                    )
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "http"
                    , port = 3182
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "repo-updater" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let exampleConfig
    : Configuration/Internal/Service
    = { namespace = None Text }

let Test/namespace/none =
      assert : (Service/generate exampleConfig).metadata.namespace ≡ None Text

let Test/namespace/some =
        assert
      :   ( Service/generate
              (exampleConfig with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  Service/generate
