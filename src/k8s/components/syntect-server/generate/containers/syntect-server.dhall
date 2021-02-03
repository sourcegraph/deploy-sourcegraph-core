let Optional/default =
      https://prelude.dhall-lang.org/v18.0.0/Optional/default.dhall sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/TCPSocketAction =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.TCPSocketAction.dhall

let Kubernetes/IntOrString =
      ../../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let Simple = ../../../../../simple/syntect-server/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container/syntect-server =
      ../../configuration/internal/container/syntect-server.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Fixtures/Container/syntect-server = (./fixtures.dhall).syntect-server

let Container/generate
    : ∀(c : Configuration/Internal/Container/syntect-server) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/syntect-server) →
        let simple = Simple.Containers.syntect-server

        let name = simple.name

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let simpleHTTPPort = simple.ports.http

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simpleHTTPPort.number
              , name = simpleHTTPPort.name
              }

        let debugPort =
              Kubernetes/ContainerPort::{
              , containerPort = 6060
              , name = Some "debug"
              }

        let livenessProbe = Some (util.HealthCheck/tok8s simple.HealthCheck)

        let probePortName = Optional/default Text "http" simpleHTTPPort.name

        let readinessProbe =
              Some
                Kubernetes/Probe::{
                , tcpSocket = Some Kubernetes/TCPSocketAction::{
                  , port = Kubernetes/IntOrString.String probePortName
                  }
                }

        in  Kubernetes/Container::{
            , image = Some image
            , name
            , env = c.envVars
            , volumeMounts = c.volumeMounts
            , ports = Some [ httpPort, debugPort ]
            , readinessProbe
            , livenessProbe
            , resources
            , securityContext
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            }

let tc = Fixtures/Container/syntect-server.Config

let Test/image/show =
        assert
      : (Container/generate tc).image ≡ Some Fixtures/global.Image.BaseShow

let Test/environment/some =
        assert
      :   ( Container/generate
              ( tc
                with envVars =
                    Fixtures/Container/syntect-server.Environment.input
              )
          ).env
        ≡ Fixtures/Container/syntect-server.Environment.expected

let Test/environment/none =
        assert
      :   ( Container/generate
              ( tc
                with envVars =
                    Fixtures/Container/syntect-server.Environment.noneInput
              )
          ).env
        ≡ Fixtures/Container/syntect-server.Environment.noneExpected

let Test/volumeMounts/some =
        assert
      :   ( Container/generate
              ( tc
                with volumeMounts =
                    Fixtures/Container/syntect-server.VolumeMounts.input
              )
          ).volumeMounts
        ≡ Fixtures/Container/syntect-server.VolumeMounts.expected

let Test/volumeMounts/none =
        assert
      :   ( Container/generate
              ( tc
                with volumeMounts =
                    Fixtures/Container/syntect-server.VolumeMounts.noneInput
              )
          ).volumeMounts
        ≡ Fixtures/Container/syntect-server.VolumeMounts.noneExpected

let Test/resources/some =
        assert
      :   ( Container/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Container/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Container/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Container/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Container/generate
