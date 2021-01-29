let configuration/volumes = ./volumes/volumes.dhall

let common = { replicas : Natural, volumes : configuration/volumes.Type }

in  common
