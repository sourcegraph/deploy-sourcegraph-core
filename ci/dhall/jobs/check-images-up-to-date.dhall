let GitHubActions = (../imports.dhall).GitHubActions

let Setup = ../setup.dhall

let SetupSteps = Setup.SetupSteps

let Job = Setup.Job

in  Job::{
    , name = Some "render-synced-images"
    , steps =
          SetupSteps
        # [ GitHubActions.Step::{
            , name = Some
                "Check that synced images from pinned deploy-sourcegraph commit are up to date"
            , run = Some "ci/check-synced-images-up-to-date.sh"
            }
          ]
    }
