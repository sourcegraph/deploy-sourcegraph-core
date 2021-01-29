-- dhall-to-yaml --explain --file src/docker-compose/gitserver-pipeline.dhall
let Gitserver/configuration = (./gitserver/configuration.dhall).configuration

let Gitserver/toList = ./gitserver/gitserver.dhall

let c =
      Gitserver/configuration::{=}
      with environment.GOMAXPROCS.value = None Text

in  Gitserver/toList c
