let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/query-runner"
      , tag = "insiders"
      , digest = Some
          "6f8b007b54f9641d4048db2af0a50522bd306b4263880b1ed4095b2064e04ab8"
      }

let hostname = "query-runner"

let ports = { http = 3183 }

let queryRunnerContainer =
      Container::{ image } ∧ { name = hostname, hostname, ports }

let Containers = { query-runner = queryRunnerContainer }

in  { Containers }
