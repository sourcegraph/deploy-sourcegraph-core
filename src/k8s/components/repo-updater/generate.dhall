let Configuration/global = ../../configuration/global.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let shape = ./shape.dhall

let Deployment/generate = ./generate/deployment.dhall

let Service/generate = ./generate/service.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Deployment/generate config.Deployment.repo-updater

        let service = Service/generate config.Service.repo-updater

        in  { Deployment.repo-updater = deployment
            , Service.repo-updater = service
            }

in  generate
