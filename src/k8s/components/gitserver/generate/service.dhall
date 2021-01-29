let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/IntOrString =
      ../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let Kubernetes/ServicePort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/Service =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let config = ../configuration/internal/service.dhall

let generate
    : ∀(c : config) → Kubernetes/Service.Type
    = λ(c : config) →
        let labels =
              toMap
                { sourcegraph-resource-requires = "no-cluster-admin"
                , app = "gitserver"
                , `app.kubernetes.io/component` = "gitserver"
                , type = "gitserver"
                , deploy = "sourcegraph"
                }

        let annotations =
              [ { mapKey = "description"
                , mapValue =
                    "Headless service that provides a stable network identity for the gitserver stateful set."
                }
              , { mapKey = "prometheus.io/port", mapValue = "6060" }
              , { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
              ]

        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some annotations
                , labels = Some labels
                , name = Some "gitserver"
                , namespace = c.namespace
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "unused"
                    , port = 10811
                    , targetPort = Some (Kubernetes/IntOrString.Int 10811)
                    }
                  ]
                , type = Some "ClusterIP"
                , clusterIP = Some "None"
                , selector = Some
                    (toMap { app = "gitserver", type = "gitserver" })
                }
              }

        in  service

in  generate
