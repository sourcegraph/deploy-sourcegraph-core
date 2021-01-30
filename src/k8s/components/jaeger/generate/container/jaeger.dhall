let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/HTTPGetAction =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall

let Simple = ../../../../../simple/jaeger/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container/jaeger =
      ../../configuration/internal/container/jaeger.dhall

let Generate
    : ∀(c : Configuration/Internal/Container/jaeger) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/jaeger) →
        let simple = Simple.Containers.jaeger

        let name = simple.name

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let ports =
              [ Kubernetes/ContainerPort::{
                , containerPort = 5775
                , protocol = Some "UDP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = simple.ports.agent.B
                , protocol = Some "UDP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = simple.ports.agent.C
                , protocol = Some "UDP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = simple.ports.agent.A
                , protocol = Some "TCP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = 16686
                , protocol = Some "TCP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = simple.ports.collector
                , protocol = Some "TCP"
                }
              ]

        in  Kubernetes/Container::{
            , args = Some [ "--memory.max-traces=20000" ]
            , image = Some image
            , name
            , ports = Some ports
            , readinessProbe = Some Kubernetes/Probe::{
              , httpGet = Some Kubernetes/HTTPGetAction::{
                , path = Some "/"
                , port = < Int : Natural | String : Text >.Int 14269
                }
              , initialDelaySeconds = Some 5
              }
            , resources
            , securityContext
            }

in  Generate
