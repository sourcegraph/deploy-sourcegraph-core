let Generate/Deployment/RedisCache = ./generate/deployment/redis-cache.dhall

let Generate/Service/RedisCache = ./generate/service/redis-cache.dhall

let Generate/PersistentVolumeClaim/RedisCache =
      ./generate/persistentvolumeclaim/redis-cache.dhall

let Generate/Deployment/RedisStore = ./generate/deployment/redis-store.dhall

let Generate/Service/RedisStore = ./generate/service/redis-store.dhall

let Generate/PersistentVolumeClaim/RedisStore =
      ./generate/persistentvolumeclaim/redis-store.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let c = Configuration/toInternal cg

        in  { Deployment =
              { redis-cache =
                  Generate/Deployment/RedisCache c.Deployment.redis-cache
              , redis-store =
                  Generate/Deployment/RedisStore c.Deployment.redis-store
              }
            , Service =
              { redis-cache = Generate/Service/RedisCache c.Service.redis-cache
              , redis-store = Generate/Service/RedisStore c.Service.redis-store
              }
            , PersistentVolumeClaim =
              { redis-cache =
                  Generate/PersistentVolumeClaim/RedisCache
                    c.PersistentVolumeClaim.redis-cache
              , redis-store =
                  Generate/PersistentVolumeClaim/RedisStore
                    c.PersistentVolumeClaim.redis-store
              }
            }

in  generate
