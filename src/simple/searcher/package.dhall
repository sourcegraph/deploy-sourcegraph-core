let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/searcher

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
