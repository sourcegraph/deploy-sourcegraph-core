let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/query-runner

let hostname = "query-runner"

let ports = { http = { number = 3183, name = Some "http" } }

let queryRunnerContainer =
      Container::{ image } ∧ { name = hostname, hostname, ports }

let Containers = { query-runner = queryRunnerContainer }

in  { Containers }
