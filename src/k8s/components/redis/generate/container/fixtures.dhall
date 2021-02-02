let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/redis-cache =
      ../../configuration/internal/container/redis-cache.dhall

let Configuration/Internal/Container/redis-store =
      ../../configuration/internal/container/redis-store.dhall

let Configuration/Internal/Container/redis-exporter =
      ../../configuration/internal/container/redis-exporter.dhall

let environment/toList = ../../configuration/environment/toList.dhall

let TestConfig/RedisCache
    : Configuration/Internal/Container/redis-cache
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = Some [ Fixtures.Environment.Secret ]
      , volumeMounts = None (List Kubernetes/VolumeMount.Type)
      }

let TestConfig/RedisStore
    : Configuration/Internal/Container/redis-store
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = Some [ Fixtures.Environment.Secret ]
      , volumeMounts = None (List Kubernetes/VolumeMount.Type)
      }

let TestConfig/RedisExporter
    : Configuration/Internal/Container/redis-exporter
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      }

in  { redis =
      { Config/RedisCache = TestConfig/RedisCache
      , Config/RedisStore = TestConfig/RedisStore
      , Config/RedisExporter = TestConfig/RedisExporter
      , Environment.expected = [ Fixtures.Environment.Secret ]
      }
    }
