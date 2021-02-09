let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/precise-code-intel-worker

let hostname = "precise-code-intel-worker"

let ports =
      { http = { number = 3188, name = Some "http" }
      , debug = { number = 6060, name = Some "debug" }
      }

let preciseCodeIntelWorkerEnv = { NUM_WORKERS = "4" }

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

let preciseCodeIntelWorkerContainer =
        Container::{ image }
      ∧ { name = hostname
        , environment = preciseCodeIntelWorkerEnv
        , hostname
        , ports
        , Healthcheck = healthCheck
        }

let Containers = { preciseCodeIntel = preciseCodeIntelWorkerContainer }

in  { Containers }
