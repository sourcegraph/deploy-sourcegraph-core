let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Simple/IndexedSearch = ../../../../../simple/indexed-search/package.dhall

let util = ../../../../../util/package.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/zoekt-indexserver =
      ../../configuration/internal/container/zoekt-indexserver.dhall

let Fixtures/Container/zoekt-indexserver =
      (./fixtures.dhall).indexed-search.ConfigIndexServer

let Container/zoekt-indexserver/generate
    : ∀(c : Configuration/Internal/Container/zoekt-indexserver) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/zoekt-indexserver) →
        let image = util.Image/show c.image

        let resources = c.resources

        let simple/zoekt-indexserver =
              Simple/IndexedSearch.Containers.indexserver

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/zoekt-indexserver.ports.http
              , name = Some "index-http"
              }

        let securityContext = c.securityContext

        in  Kubernetes/Container::{
            , env = c.envVars
            , image = Some image
            , name = "zoekt-indexserver"
            , ports = Some [ httpPort ]
            , resources
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            , volumeMounts = c.volumeMounts
            }

let tc = Fixtures/Container/zoekt-indexserver

let Test/image/show =
        assert
      :   (Container/zoekt-indexserver/generate tc).image
        ≡ Some Fixtures/global.Image.BaseShow

let Test/resources/some =
        assert
      :   ( Container/zoekt-indexserver/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Container/zoekt-indexserver/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Container/zoekt-indexserver/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Container/zoekt-indexserver/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Container/zoekt-indexserver/generate
