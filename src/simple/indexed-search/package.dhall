let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let webserverImage = Simple/images.sourcegraph/indexed-searcher

let webserverHttpPort = { number = 6070, name = Some "http" }

let indexserverImage = Simple/images.sourcegraph/search-indexer

let indexserverHttpPort = { number = 6072, name = Some "http" }

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
