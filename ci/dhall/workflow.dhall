let GitHubActions = (./imports.dhall).GitHubActions

let shellcheck = ./jobs/shellcheck.dhall

let shfmt = ./jobs/shfmt.dhall

let checkPipeline = ./jobs/check-rendered-pipeline-up-to-date.dhall

let checkImages = ./jobs/check-images-up-to-date.dhall

let dhallFormat = ./jobs/dhall-format.dhall

let dhallLint = ./jobs/dhall-lint.dhall

let dhallCheck = ./jobs/dhall-check.dhall

let dhallFreeze = ./jobs/dhall-freeze.dhall

let prettier = ./jobs/prettier.dhall

in  GitHubActions.Workflow::{
    , name = "CI"
    , on = GitHubActions.On::{ push = Some GitHubActions.Push::{=} }
    , jobs = toMap
        { shellcheck
        , shfmt
        , dhallFormat
        , dhallLint
        , checkImages
        , dhallCheck
        , dhallFreeze
        , checkPipeline
        , prettier
        }
    }
