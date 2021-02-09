let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let redisCacheImage = Simple/images.sourcegraph/redis-cache

let redisExporterImage = Simple/images.sourcegraph/redis_exporter

let redisStoreImage = Simple/images.sourcegraph/redis-store

let redisPort = { number = 6379, name = Some "redis" }

let redisExporterPort = { number = 9121, name = Some "redisexp" }

let dataDir = "/redis-data"

let volumes = { redis-data = dataDir }

let redisHealthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , port = redisPort
        , scheme = util.HealthCheck/Scheme.TCP
        , initialDelaySeconds = Some 30
        , timeoutSeconds = Some 5
        }

let redisCacheContainer =
        Container::{ image = redisCacheImage }
      ∧ { volumes
        , name = "redis-cache"
        , ports.redis = redisPort
        , HealthCheck = redisHealthCheck
        }

let redisStoreContainer =
        Container::{ image = redisStoreImage }
      ∧ { volumes
        , name = "redis-store"
        , ports.redis = redisPort
        , HealthCheck = redisHealthCheck
        }

let redisExporterContainer =
        Container::{ image = redisExporterImage }
      ∧ { name = "redis-exporter", ports.redisexp = redisExporterPort }

let Containers =
      { redis-cache = redisCacheContainer
      , redis-store = redisStoreContainer
      , redis-exporter = redisExporterContainer
      }

in  { Containers }
