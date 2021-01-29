let configuration = ./github-proxy/configuration.dhall

let toList = ./github-proxy/github-proxy.dhall

let c
    : configuration.Type
    = configuration::{=}

in  toList c
