let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServicePort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Kubernetes/IntOrString =
      ../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let Configuration/Internal/Service = ../configuration/internal/service.dhall

let name = "pgsql"

let appLabel = { app = name }

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = name }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let Simple/Postgres = ../../../../simple/postgres/package.dhall

let Service/generate
    : ∀(c : Configuration/Internal/Service) → Kubernetes/Service.Type
    = λ(c : Configuration/Internal/Service) →
        let namespace = c.namespace

        let labels =
              toMap
                (   appLabel
                  ∧ deploySourcegraphLabel
                  ∧ componentLabel
                  ∧ noClusterAdminLabel
                )

        let simple/port = Simple/Postgres.Containers.pgsql.ports.database

        let targetPort =
              merge
                { Some = λ(p : Text) → Kubernetes/IntOrString.String p
                , None = Kubernetes/IntOrString.Int simple/port.number
                }
                simple/port.name

        let port =
              Kubernetes/ServicePort::{
              , name = Some name
              , port = simple/port.number
              , targetPort = Some targetPort
              }

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , name = Some name
                , annotations = Some
                  [ { mapKey = "prometheus.io/port", mapValue = "9187" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some labels
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some [ port ]
                , selector = Some (toMap appLabel)
                , type = Some "ClusterIP"
                }
              }

        in  service

let exampleConfig
    : Configuration/Internal/Service
    = { namespace = None Text }

let example1 =
      assert : (Service/generate exampleConfig).metadata.namespace ≡ None Text

let example2 =
        assert
      :   ( Service/generate (exampleConfig with namespace = Some "test")
          ).metadata.namespace
        ≡ Some "test"

in  Service/generate
