-- dhall-to-yaml --explain --file src/docker-compose/query-runner-pipeline.dhall
let QueryRunner/configuration =
      (./query-runner/configuration.dhall).configuration

let QueryRunner/toList = ./query-runner/query-runner.dhall

let c = QueryRunner/configuration::{=}

in  QueryRunner/toList c
