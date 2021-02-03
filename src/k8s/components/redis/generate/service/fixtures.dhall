let Configuration/Internal/Service = ../../configuration/internal/service.dhall

let TestConfigRedisCache
    : Configuration/Internal/Service
    = { namespace = None Text }

let TestConfigRedisStore
    : Configuration/Internal/Service
    = { namespace = None Text }

in  { redis =
      { Config/RedisCache = TestConfigRedisCache
      , Config/RedisStore = TestConfigRedisStore
      }
    }
