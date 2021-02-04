let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/postgres-11.4"
      , tag = "insiders"
      , digest = Some
          "a55fea6638d478c2368c227d06a1a2b7a2056b693967628427d41c92d9209e97"
      }

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
