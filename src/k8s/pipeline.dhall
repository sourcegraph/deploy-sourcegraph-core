-- dhall-to-yaml --explain --file src/k8s/pipeline.dhall
let Configuration/global = ./configuration/global.dhall

let generate = ./generate.dhall

let c
    : Configuration/global.Type
    = Configuration/global::{=}

in  generate c
