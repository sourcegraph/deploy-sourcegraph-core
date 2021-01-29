let GitHubActions = (../imports.dhall).GitHubActions

let Setup = ../setup.dhall

let SetupSteps = Setup.SetupSteps

let Job = Setup.Job

in  Job::{
    , name = Some "dhall-freeze"
    , steps =
          SetupSteps
        # [ GitHubActions.Step::{
            , name = Some "Check that dhall files are frozen"
            , run = Some "just freeze-dhall"
            , env = Some (toMap { CHECK = "true" })
            }
          ]
    }
