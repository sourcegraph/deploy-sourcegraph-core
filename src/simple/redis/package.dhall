let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let redisCacheImage =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/redis-cache"
      , tag = "insiders"
      , digest = Some
          "7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56"
      }

let redisExporterImage =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/redis_exporter"
      , tag = "84464_2021-01-15_c2e4c28"
      , digest = Some
          "f3f51453e4261734f08579fe9c812c66ee443626690091401674be4fb724da70"
      }

let redisStoreImage =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/redis-store"
      , tag = "insiders"
      , digest = Some
          "e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168"
      }

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
