let Configuration/global = ./configuration/global.dhall

let generate-list = ./generate-list.dhall

let c
    : Configuration/global.Type
    = Configuration/global::{=}
      with Global.storageClassname = Some "sourcegraph"

in  generate-list c
