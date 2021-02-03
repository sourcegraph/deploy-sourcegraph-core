let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/frontend"
      , tag = "insiders"
      , digest = Some
          "6634dedb1f7e80b8f7b781ae169a98f578ac9d42cdf7b21597ee295ebd53a3e8"
      }

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
