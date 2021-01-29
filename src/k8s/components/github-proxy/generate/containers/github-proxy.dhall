let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Simple = ../../../../../simple/github-proxy/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container/github-proxy =
      ../../configuration/internal/container/github-proxy.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Fixtures/Container/github-proxy = (./fixtures.dhall).github-proxy

let Container/generate
    : ∀(c : Configuration/Internal/Container/github-proxy) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/github-proxy) →
        let simple = Simple.Containers.github-proxy

        let name = simple.name

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple.ports.http
              , name = Some "http"
              }

        in  Kubernetes/Container::{
            , image = Some image
            , name
            , env = c.envVars
            , volumeMounts = c.volumeMounts
            , ports = Some [ httpPort ]
            , resources
            , securityContext
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            }

let tc = Fixtures/Container/github-proxy.Config

let Test/image/show =
        assert
      : (Container/generate tc).image ≡ Some Fixtures/global.Image.BaseShow

let Test/environment =
        assert
      :   (Container/generate tc).env
        ≡ Some Fixtures/Container/github-proxy.Environment.expected

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
