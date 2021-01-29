let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Simple/Searcher = ../../../../../simple/searcher/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container =
      ../../configuration/internal/container/searcher.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Fixtures/Container/searcher = (./fixtures.dhall).searcher

let Container/generate
    : ∀(c : Configuration/Internal/Container) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container) →
        let simple/searcher = Simple/Searcher.Containers.searcher

        let image = util.Image/show c.image

        let k8sProbe = util.HealthCheck/tok8s simple/searcher.healthCheck

        let probe = k8sProbe with failureThreshold = Some 3

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = None Natural

        let securityContext = c.securityContext

        let resources = c.resources

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/searcher.ports.http
              , name = Some "http"
              }

        let container =
              Kubernetes/Container::{
              , env = c.envVars
              , image = Some image
              , name = "searcher"
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

        in  container

let tc = Fixtures/Container/searcher.Config

let Test/image/show =
        assert
      : (Container/generate tc).image ≡ Some Fixtures/global.Image.BaseShow

let Test/environment =
        assert
      :   (Container/generate tc).env
        ≡ Some Fixtures/Container/searcher.Environment.expected

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
