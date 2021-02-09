let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/syntax-highlighter

let hostname = "syntect-server"

let ports = { http = { number = 9238, name = Some "http" } }

let cacheDir = "/mnt/cache"

let volumes = { CACHE_DIR = cacheDir }

let HealthCheck =
      util.HealthCheck.Network
        util.NetworkHealthCheck::{
        , endpoint = "/health"
        , port = ports.http
        , scheme = util.HealthCheck/Scheme.HTTP
        , initialDelaySeconds = Some 5
        , retries = Some 3
        , timeoutSeconds = Some 5
        }

let Container/syntect-server =
        Container::{ image }
      ∧ { name = hostname, hostname, ports, HealthCheck, volumes }

let Containers = { syntect-server = Container/syntect-server }

in  { Containers }
