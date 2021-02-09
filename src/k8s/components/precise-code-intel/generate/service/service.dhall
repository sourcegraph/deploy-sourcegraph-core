let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/Internal/Service = ../../configuration/internal/service.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Simple = ../../../../../simple/precise-code-intel/package.dhall

let Fixtures/precise-code-intel/service = ./fixtures.dhall

let Service/generate
    : ∀(c : Configuration/Internal/Service) → Kubernetes/Service.Type
    = λ(c : Configuration/Internal/Service) →
        let namespace = c.namespace

        let httpPort = Simple.Containers.preciseCodeIntel.ports.http

        let debugPort = Simple.Containers.preciseCodeIntel.ports.debug

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "prometheus.io/port", mapValue = "6060" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                  [ { mapKey = "app", mapValue = "precise-code-intel-worker" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "precise-code-intel"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "precise-code-intel-worker"
                , namespace
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "http"
                    , port = httpPort
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  , Kubernetes/ServicePort::{
                    , name = Some "debug"
                    , port = debugPort
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "debug")
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "precise-code-intel-worker" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let tc = Fixtures/precise-code-intel/service.precise-code-intel.Config

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
