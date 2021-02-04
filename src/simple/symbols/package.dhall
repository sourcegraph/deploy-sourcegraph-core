let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/symbols"
      , tag = "insiders"
      , digest = Some
          "0bd03b9faec72499a595f08dcd65b28944eaeccdc1adc5d768edfba2a71f657b"
      }

let cacheDir = "/mnt/cache"

let volumes = { CACHE_DIR = cacheDir }

let hostname = "symbols"

let ports = { http = { number = 3184, name = Some "http" } }

let symbolsEnvironment =
      { CACHE_DIR = { name = "CACHE_DIR", value = cacheDir } }

let healthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/healthz"
        , port = ports.http
        , scheme = util.HealthCheck/Scheme.HTTP
        , initialDelaySeconds = Some 60
        , retries = Some 3
        , timeoutSeconds = Some 5
        , intervalSeconds = Some 5
        }

let symbolsContainer =
        Container::{ image }
      ∧ { name = hostname
        , environment = symbolsEnvironment
        , hostname
        , volumes
        , ports
        , healthCheck
        }

let Containers = { symbols = symbolsContainer }

in  { Containers }
