let Sourcegraph = ../../package.dhall

let c
    : Sourcegraph.Configuration.Type
    = Sourcegraph.Configuration::{=}

in  Sourcegraph.Generate c
