let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Simple/Redis = ../../../../../simple/redis/package.dhall

let util = ../../../../../util/package.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/redis-store =
      ../../configuration/internal/container/redis-store.dhall

let Fixtures/Container/redis-store = (./fixtures.dhall).redis

let Container/redis-store/generate
    : ∀(c : Configuration/Internal/Container/redis-store) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/redis-store) →
        let image = util.Image/show c.image

        let resources = c.resources

        let simple/redis-store = Simple/Redis.Containers.redis-store

        let k8sProbe = util.HealthCheck/tok8s simple/redis-store.HealthCheck

        let probe = k8sProbe with failureThreshold = None Natural

        let livenessProbe =
              probe
              with periodSeconds = None Natural
              with timeoutSeconds = None Natural

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = Some 5
              with timeoutSeconds = None Natural

        let port = simple/redis-store.ports.redis

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = port.number
              , name = port.name
              }

        let securityContext = c.securityContext

        in  Kubernetes/Container::{
            , env = c.envVars
            , image = Some image
            , livenessProbe = Some livenessProbe
            , name = "redis-store"
            , ports = Some [ httpPort ]
            , readinessProbe = Some readinessProbe
            , resources
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            , volumeMounts = c.volumeMounts
            }

let tc = Fixtures/Container/redis-store.Config/RedisStore

let Test/image/show =
        assert
      :   (Container/redis-store/generate tc).image
        ≡ Some Fixtures/global.Image.BaseShow

let Test/environment =
        assert
      :   (Container/redis-store/generate tc).env
        ≡ Some Fixtures/Container/redis-store.Environment.expected

let Test/resources/some =
        assert
      :   ( Container/redis-store/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Container/redis-store/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Container/redis-store/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Container/redis-store/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Container/redis-store/generate
