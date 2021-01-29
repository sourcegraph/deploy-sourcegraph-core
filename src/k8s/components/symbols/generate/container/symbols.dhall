let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Simple/Symbols = ../../../../../simple/symbols/package.dhall

let util = ../../../../../util/package.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/symbols =
      ../../configuration/internal/container/symbols.dhall

let Fixtures/Container/symbols = (./fixtures.dhall).symbols

let Container/symbols/generate
    : ∀(c : Configuration/Internal/Container/symbols) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/symbols) →
        let image = util.Image/show c.image

        let resources = c.resources

        let simple/symbols = Simple/Symbols.Containers.symbols

        let k8sProbe = util.HealthCheck/tok8s simple/symbols.healthCheck

        let probe = k8sProbe with failureThreshold = None Natural

        let livenessProbe = probe with periodSeconds = None Natural

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = None Natural

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/symbols.ports.http
              , name = Some "http"
              }

        let securityContext = c.securityContext

        in  Kubernetes/Container::{
            , env = c.envVars
            , image = Some image
            , livenessProbe = Some livenessProbe
            , name = "symbols"
            , ports = Some
              [ httpPort
              , Kubernetes/ContainerPort::{
                , containerPort = 6060
                , name = Some "debug"
                }
              ]
            , readinessProbe = Some readinessProbe
            , resources
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            , volumeMounts = c.volumeMounts
            }

let tc = Fixtures/Container/symbols.Config

let Test/image/show =
        assert
      :   (Container/symbols/generate tc).image
        ≡ Some Fixtures/global.Image.BaseShow

let Test/environment =
        assert
      :   (Container/symbols/generate tc).env
        ≡ Some Fixtures/Container/symbols.Environment.expected

let Test/resources/some =
        assert
      :   ( Container/symbols/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Container/symbols/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Container/symbols/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Container/symbols/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Container/symbols/generate
