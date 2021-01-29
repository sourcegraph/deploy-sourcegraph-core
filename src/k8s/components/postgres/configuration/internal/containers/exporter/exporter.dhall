let shared = ../shared.dhall

let Environment = ./environment/environment.dhall

let exporter = shared ⩓ { environment : Environment.Type }

in  exporter
