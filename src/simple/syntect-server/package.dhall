let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/syntax-highlighter"
      , tag = "insiders"
      , digest = Some
          "83ff65809e6647b466bd400de4c438a32feeabe8e791b12e15c67c84529ad2de"
      }

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
