let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/repo-updater

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
