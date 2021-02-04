let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../container/fixtures.dhall

let Configuration/Internal/Deployment/RedisCache =
      ../../configuration/internal/deployment/redis-cache.dhall

let Configuration/Internal/Deployment/RedisStore =
      ../../configuration/internal/deployment/redis-store.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let TestConfig/RedisCache
    : Configuration/Internal/Deployment/RedisCache
    = { Containers =
        { redis-cache = Fixtures/containers.redis.Config/RedisCache
        , redis-exporter = Fixtures/containers.redis.Config/RedisExporter
        }
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      , additionalVolumes = [] : List Kubernetes/Volume.Type
      }

let TestConfig/RedisStore
    : Configuration/Internal/Deployment/RedisStore
    = { Containers =
        { redis-store = Fixtures/containers.redis.Config/RedisStore
        , redis-exporter = Fixtures/containers.redis.Config/RedisExporter
        }
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      , additionalVolumes = [] : List Kubernetes/Volume.Type
      }

let shared =
      { Volumes =
        { input = [ Fixtures/global.Volumes.NFS, Fixtures/global.Volumes.NFS ]
        , emptyInput = None (List Kubernetes/Volume.Type)
        , expected =
          [ Fixtures/global.Volumes.NFS, Fixtures/global.Volumes.NFS ]
        , emptyExpected = None (List Kubernetes/Volume.Type)
        }
      , Sidecars =
        { input = [ Fixtures/global.SideCars.Baz, Fixtures/global.SideCars.Foo ]
        , emptyInput = [] : List Kubernetes/Container.Type
        , expected =
          [ Fixtures/global.SideCars.Baz, Fixtures/global.SideCars.Foo ]
        , emptyExpected = [] : List Kubernetes/Container.Type
        }
      }

in  { redis =
      { redis-cache = { Config = TestConfig/RedisCache } ∧ shared
      , redis-store = { Config = TestConfig/RedisStore } ∧ shared
      }
    }
