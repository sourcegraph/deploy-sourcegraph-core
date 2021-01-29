-- dhall-to-yaml --explain --file src/docker-compose/indexed-search-pipeline.dhall
let IndexedSearch/configuration =
      (./indexed-search/configuration.dhall).configuration

let IndexedSearch/toList = ./indexed-search/indexed-search.dhall

let c =
      IndexedSearch/configuration::{=}
      with environment.GOMAXPROCS.value = None Text
      with healthcheck.interval = Some "10s"

in  IndexedSearch/toList c
