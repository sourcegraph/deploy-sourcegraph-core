-- dhall-to-yaml --explain --file src/k8s/pipeline.dhall
let Sourcegraph = ./package.dhall

let c
    : Sourcegraph.Configuration.Type
    = Sourcegraph.Configuration::{=}

in  c
