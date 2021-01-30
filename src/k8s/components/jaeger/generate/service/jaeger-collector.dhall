let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Simple/Jaeger = ../../../../../simple/jaeger/package.dhall

let Configuration/internal/service = ../../configuration/internal/service.dhall

let Generate
    : ∀(c : Configuration/internal/service) → Kubernetes/Service.Type
    = λ(c : Configuration/internal/service) →
        let namespace = c.namespace

        in  Kubernetes/Service::{
            , metadata = Kubernetes/ObjectMeta::{
              , labels = Some
                  ( toMap
                      { app = "jaeger"
                      , `app.kubernetes.io/component` = "jaeger"
                      , `app.kubernetes.io/name` = "jaeger"
                      , deploy = "sourcegraph"
                      , sourcegraph-resource-requires = "no-cluster-admin"
                      }
                  )
              , name = Some "jaeger-collector"
              , namespace
              }
            , spec = Some Kubernetes/ServiceSpec::{
              , ports = Some
                [ Kubernetes/ServicePort::{
                  , name = Some "jaeger-collector-tchannel"
                  , port = Simple/Jaeger.Containers.jaeger.ports.collector
                  , protocol = Some "TCP"
                  , targetPort = Some
                      (< Int : Natural | String : Text >.Int 14267)
                  }
                , Kubernetes/ServicePort::{
                  , name = Some "jaeger-collector-http"
                  , port = 14268
                  , protocol = Some "TCP"
                  , targetPort = Some
                      (< Int : Natural | String : Text >.Int 14268)
                  }
                , Kubernetes/ServicePort::{
                  , name = Some "jaeger-collector-grpc"
                  , port = 14250
                  , protocol = Some "TCP"
                  , targetPort = Some
                      (< Int : Natural | String : Text >.Int 14250)
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
