let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Simple/Redis = ../../../../../simple/redis/package.dhall

let util = ../../../../../util/package.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/redis-exporter =
      ../../configuration/internal/container/redis-exporter.dhall

let Fixtures/Container/redis-exporter = (./fixtures.dhall).redis

let Container/redis-exporter/generate
    : ∀(c : Configuration/Internal/Container/redis-exporter) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/redis-exporter) →
        let image = util.Image/show c.image

        let resources = c.resources

        let simple/redis-exporter = Simple/Redis.Containers.redis-exporter

        let redisexpPort =
              Kubernetes/ContainerPort::{
              , containerPort = simple/redis-exporter.ports.redisexp
              , name = Some "redisexp"
              }

        let securityContext = c.securityContext

        in  Kubernetes/Container::{
            , image = Some image
            , name = "redis-exporter"
            , ports = Some [ redisexpPort ]
            , resources
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            }

let tc = Fixtures/Container/redis-exporter.Config/RedisExporter

let Test/image/show =
        assert
      :   (Container/redis-exporter/generate tc).image
        ≡ Some Fixtures/global.Image.BaseShow

let Test/resources/some =
        assert
      :   ( Container/redis-exporter/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Container/redis-exporter/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Container/redis-exporter/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Container/redis-exporter/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Container/redis-exporter/generate
