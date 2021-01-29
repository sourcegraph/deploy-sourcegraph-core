-- dhall-to-yaml --explain --file src/docker-compose/frontend-pipeline.dhall
let Frontend/configuration = (./frontend/configuration.dhall).configuration

let Frontend/toList = ./frontend/frontend.dhall

let c =
      Frontend/configuration::{=}
      with environment.GOMAXPROCS.value = None Text
      with healthcheck.interval = Some "10s"

in  Frontend/toList c
