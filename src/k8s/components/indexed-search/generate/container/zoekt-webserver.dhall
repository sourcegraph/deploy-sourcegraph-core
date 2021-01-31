let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Simple/IndexedSearch = ../../../../../simple/indexed-search/package.dhall

let util = ../../../../../util/package.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/zoekt-webserver =
      ../../configuration/internal/container/zoekt-webserver.dhall

let Fixtures/Container/zoekt-webserver =
      (./fixtures.dhall).indexed-search.ConfigIndexServer

let Container/zoekt-webserver/generate
    : ∀(c : Configuration/Internal/Container/zoekt-webserver) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/zoekt-webserver) →
        let image = util.Image/show c.image

        let resources = c.resources

        let simple/zoekt-webserver = Simple/IndexedSearch.Containers.webserver

        let k8sProbe = util.HealthCheck/tok8s simple/zoekt-webserver.HealthCheck

        let readinessProbe
            : Kubernetes/Probe.Type
            = k8sProbe
              with periodSeconds = Some 5
              with failureThreshold = Some 3
              with initialDelaySeconds = None Natural

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/zoekt-webserver.ports.http
              , name = Some "http"
              }

        let securityContext = c.securityContext

        in  Kubernetes/Container::{
            , env = c.envVars
            , image = Some image
            , name = "zoekt-webserver"
            , ports = Some [ httpPort ]
            , readinessProbe = Some readinessProbe
            , resources
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            , volumeMounts = c.volumeMounts
            }

let tc = Fixtures/Container/zoekt-webserver

let Test/image/show =
        assert
      :   (Container/zoekt-webserver/generate tc).image
        ≡ Some Fixtures/global.Image.BaseShow

let Test/resources/some =
        assert
      :   ( Container/zoekt-webserver/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Container/zoekt-webserver/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Container/zoekt-webserver/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Container/zoekt-webserver/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Container/zoekt-webserver/generate
