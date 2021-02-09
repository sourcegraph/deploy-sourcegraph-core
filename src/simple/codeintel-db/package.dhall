let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/codeintel-db

let pgsqlPort = { number = 5432, name = Some "pgsql" }

let dataDir = "/data"

let volumes = { data = dataDir }

let healthCheck =
      util.HealthCheck.Exec
        util.ExecHealthCheck::{
        , command = util.Command.Exec [ "/liveness.sh" ]
        , initialDelaySeconds = Some 15
        }

let pgsqlContainer =
        Container::{ image }
      ∧ { volumes
        , name = "pgsql"
        , ports.database = pgsqlPort
        , HealthCheck = healthCheck
        }
      ∧ { cpus = 4.0, memory = "2g" }

let Containers = { pgsql = pgsqlContainer }

in  { Containers }
