let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Simple = ../../../../../simple/query-runner/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container =
      ../../configuration/internal/container/query-runner.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Fixtures/Container/query-runner = (./fixtures.dhall).query-runner

let Container/generate
    : ∀(c : Configuration/Internal/Container) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container) →
        let simple = Simple.Containers.query-runner

        let name = simple.name

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let port = simple.ports.http

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = port.number
              , name = port.name
              }

        let container =
              Kubernetes/Container::{
              , image = Some image
              , env = c.envVars
              , volumeMounts = c.volumeMounts
              , name
              , ports = Some [ httpPort ]
              , resources
              , securityContext
              , terminationMessagePolicy = Some "FallbackToLogsOnError"
              }

        in  container

let tc = Fixtures/Container/query-runner.Config

let Test/image/show =
        assert
      : (Container/generate tc).image ≡ Some Fixtures/global.Image.BaseShow

let Test/environment =
        assert
      :   (Container/generate tc).env
        ≡ Some Fixtures/Container/query-runner.Environment.expected

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
