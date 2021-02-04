let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/searcher"
      , tag = "insiders"
      , digest = Some
          "1270809512e5f61eb0867e82c08f0f98fa58b4d282ffbbdf23c5ace095132831"
      }

let cacheDir = "/mnt/cache"

let volumes = { CACHE_DIR = cacheDir }

let hostname = "searcher"

let ports = { http = 3181, debug = 6060 }

let searcherEnvironment =
      { CACHE_DIR = { name = "CACHE_DIR", value = cacheDir } }

let httpPort = 3181

let healthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/healthz"
        , port = { number = httpPort, name = Some "http" }
        , scheme = util.HealthCheck/Scheme.HTTP
        , timeoutSeconds = Some 5
        , intervalSeconds = Some 5
        , retries = Some 3
        }

let searcherContainer =
        Container::{ image }
      ∧ { name = hostname
        , environment = searcherEnvironment
        , hostname
        , volumes
        , ports
        , healthCheck
        }

let Containers = { searcher = searcherContainer }

in  { Containers }
