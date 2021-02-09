let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/precise-code-intel-worker

let hostname = "precise-code-intel-worker"

let ports = { http = 3188, debug = 6060 }

let preciseCodeIntelWorkerEnv = { NUM_WORKERS = "4" }

let healthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/healthz"
        , port = { number = ports.http, name = Some "http" }
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
