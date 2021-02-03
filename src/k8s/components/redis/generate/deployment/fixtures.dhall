let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../container/fixtures.dhall

let Configuration/Internal/Deployment/RedisCache =
      ../../configuration/internal/deployment/redis-cache.dhall

let Configuration/Internal/Deployment/RedisStore =
      ../../configuration/internal/deployment/redis-store.dhall

let TestConfig/RedisCache
    : Configuration/Internal/Deployment/RedisCache
    = { Containers =
        { redis-cache = Fixtures/containers.redis.Config/RedisCache
        , redis-exporter = Fixtures/containers.redis.Config/RedisExporter
        }
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      }

let TestConfig/RedisStore
    : Configuration/Internal/Deployment/RedisStore
    = { Containers =
        { redis-store = Fixtures/containers.redis.Config/RedisStore
        , redis-exporter = Fixtures/containers.redis.Config/RedisExporter
        }
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      }

in  { redis =
      { Config/RedisCache = TestConfig/RedisCache
      , Config/RedisStore = TestConfig/RedisStore
      }
    }
