let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/precise-code-intel-worker"
      , tag = "insiders"
      , digest = Some
          "0bd03b9faec72499a595f08dcd65b28944eaeccdc1adc5d768edfba2a71f657b"
      }

let hostname = "precise-code-intel-worker"

let ports = { http = 3188, debug = 6060 }

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
