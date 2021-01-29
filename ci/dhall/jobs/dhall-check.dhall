let GitHubActions = (../imports.dhall).GitHubActions

let Setup = ../setup.dhall

let SetupSteps = Setup.SetupSteps

let Job = Setup.Job

in  Job::{
    , name = Some "dhall-check"
    , steps =
          SetupSteps
        # [ GitHubActions.Step::{
            , name = Some "Check that all dhall files typecheck"
            , run = Some "just check-dhall"
            }
          ]
    }
