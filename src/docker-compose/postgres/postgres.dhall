let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let Simple/Postgres = (../../simple/postgres/package.dhall).Containers.pgsql

let Volume/show = ../functions/volumes-show.dhall

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "pgsql"

        let image = util.Image/show c.image

        let volume = Volume/show "pgsql" "${Simple/Postgres.volumes.data}/"

        let healthcheck =
              (util.HealthCheck/toDockerCompose Simple/Postgres.HealthCheck)
              with interval = Some "10s"
              with timeout = Some "1s"
              with retries = Some 3

        in  component::{
            , container_name = name
            , cpus = Simple/Postgres.cpus
            , mem_limit = Simple/Postgres.memory
            , environment = None (List Text)
            , volumes = [ volume ]
            , healthcheck = Some healthcheck
            , image
            }

in  generate
