let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container


let jagerImage =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/search-indexer"
      , tag = "insiders"
      , digest = Some
          "89fa7d5eac6f9f3e8893a482650dffcea4d22be993328427679af7e3ddd08e10"
      }

let indexserverHttpPort = 6072

let dataDir = "/data"

let volumes = { data = dataDir }

let webserverHealthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/healthz"
        , port = webserverHttpPort
        , scheme = util.HealthCheck/Scheme.HTTP
        , initialDelaySeconds = Some 5
        , timeoutSeconds = Some 5
        }

let webserverContainer =
        Container::{ image = webserverImage }
      ∧ { volumes
        , name = "zoekt-webserver"
        , ports.http = webserverHttpPort
        , HealthCheck = webserverHealthCheck
        }

let indexserverContainer =
        Container::{ image = indexserverImage }
      ∧ { volumes
        , name = "zoekt-indexserver"
        , ports.http = indexserverHttpPort
        }

let Containers =
      { webserver = webserverContainer, indexserver = indexserverContainer }

in  { Containers }
