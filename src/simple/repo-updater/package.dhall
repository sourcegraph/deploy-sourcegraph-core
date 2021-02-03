let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/repo-updater"
      , tag = "insiders"
      , digest = Some
          "811b345d8b06cc411c4138519652b33dbf1be3d6db2e0ed5d7a31e4d8c0ae266"
      }

let httpPort = { number = 3182, name = Some "http" }

let healthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/healthz"
        , port = httpPort
        , scheme = util.HealthCheck/Scheme.HTTP
        , timeoutSeconds = Some 5
        , intervalSeconds = Some 1
        , retries = Some 3
        }

let cacheDir = "/mnt/cache"

let volumes = { cache = cacheDir }

let repoUpdaterContainer =
        Container::{ image }
      ∧ { volumes
        , name = "repo-updater"
        , ports.http = httpPort
        , HealthCheck = healthCheck
        }

let Containers = { repo-updater = repoUpdaterContainer }

in  { Containers }
