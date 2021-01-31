let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/HTTPGetAction =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall

let Simple = ../../../../../simple/jaeger/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container/jaeger =
      ../../configuration/internal/container/jaeger.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Fixtures/Container/jaeger = (./fixtures.dhall).jaeger

let Generate
    : ∀(c : Configuration/Internal/Container/jaeger) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/jaeger) →
        let simple = Simple.Containers.jaeger

        let name = simple.name

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let environment = c.envVars

        let volumeMounts = c.volumeMounts

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
            , env = environment
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
            , volumeMounts
            }

let tc = Fixtures/Container/jaeger.Config

let Test/image/show =
      assert : (Generate tc).image ≡ Some Fixtures/global.Image.BaseShow

let Test/resources/some =
        assert
      :   ( Generate (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

let Test/volumeMounts/none =
        assert
      :   ( Generate
              (tc with volumeMounts = None (List Kubernetes/VolumeMount.Type))
          ).volumeMounts
        ≡ None (List Kubernetes/VolumeMount.Type)

let Test/volumeMounts/none =
        assert
      :   ( Generate
              ( tc
                with volumeMounts = Some [ Fixtures/global.VolumeMounts.Lights ]
              )
          ).volumeMounts
        ≡ Some [ Fixtures/global.VolumeMounts.Lights ]

in  Generate
