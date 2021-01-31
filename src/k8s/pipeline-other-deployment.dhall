-- dhall-to-yaml --explain --file src/k8s/pipeline.dhall
let Configuration/global = ./configuration/global.dhall

let generate = ./generate.dhall

let c
    : Configuration/global.Type
    = Configuration/global::{=}
      with Global.storageClassname = Some "sourcegraph"
      with Global.namespace = Some "prod"

in  generate c
