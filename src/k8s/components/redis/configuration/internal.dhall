let Configuration/Internal/Service = ./internal/service.dhall

let RedisCache = ./internal/deployment/redis-cache.dhall

let RedisStore = ./internal/deployment/redis-store.dhall

let Configuration/Internal/PersistentVolumeClaim =
      ./internal/persistentvolumeclaim.dhall

let configuration =
      { Deployment : { redis-cache : RedisCache, redis-store : RedisStore }
      , Service :
          { redis-cache : Configuration/Internal/Service
          , redis-store : Configuration/Internal/Service
          }
      , PersistentVolumeClaim :
          { redis-cache : Configuration/Internal/PersistentVolumeClaim
          , redis-store : Configuration/Internal/PersistentVolumeClaim
          }
      }

in  configuration
