let Optional/default =
      https://prelude.dhall-lang.org/v18.0.0/Optional/default.dhall sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/Internal/Service = ../../configuration/internal/service.dhall

let Fixtures/syntect-server/service = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Simple = ../../../../../simple/syntect-server/package.dhall

let Service/generate
    : ∀(c : Configuration/Internal/Service) → Kubernetes/Service.Type
    = λ(c : Configuration/Internal/Service) →
        let namespace = c.namespace

        let port = Simple.Containers.syntect-server.ports.http

        let portName = Optional/default Text "http" port.name

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , labels = Some
                  [ { mapKey = "app", mapValue = "syntect-server" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "syntect-server"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "syntect-server"
                , namespace
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some portName
                    , port = port.number
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String portName)
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "syntect-server" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let tc = Fixtures/syntect-server/service.syntect-server.Config

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
