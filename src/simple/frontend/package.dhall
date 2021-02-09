let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/frontend

let cacheDir = "/mnt/cache"

let volumes = { CACHE_DIR = cacheDir }

let frontendEnvironment =
      { CACHE_DIR = { name = "CACHE_DIR", value = cacheDir }
      , SRC_GIT_SERVERS =
        { name = "SRC_GIT_SERVERS", value = "gitserver-0.gitserver:3178" }
      }

let frontendHostname = "sourcegraph-frontend"

let httpPort = { number = 3080, name = Some "http" }

let healthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/healthz"
        , port = httpPort
        , scheme = util.HealthCheck/Scheme.HTTP
        , initialDelaySeconds = Some 300
        , retries = Some 3
        , timeoutSeconds = Some 10
        , intervalSeconds = Some 5
        }

let frontendContainer =
        Container::{ image }
      ∧ { name = frontendHostname
        , hostname = frontendHostname
        , environment = frontendEnvironment
        , volumes
        , ports.http = 3080
        }

let internalHostname = "sourcegraph-frontend-internal"

let internalContainer =
        frontendContainer
      ⫽ { name = internalHostname
        , hostname = internalHostname
        , ports.http-internal = 3090
        }

let Containers =
      { frontend = frontendContainer ∧ { HealthCheck = healthCheck }
      , frontendInternal = internalContainer
      }

let SRC_FRONTEND_INTERNAL =
      "${internalContainer.hostname}:${Natural/show
                                         internalContainer.ports.http-internal}"

in  { Containers, SRC_FRONTEND_INTERNAL }
