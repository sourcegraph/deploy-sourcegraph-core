let Generate/Deployment = ./generate/deployment/deployment.dhall

let Generate/Service = ./generate/service/service.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Generate/Deployment config.Deployment.github-proxy

        let service = Generate/Service config.Service.github-proxy

        in  { Deployment.github-proxy = deployment
            , Service.github-proxy = service
            }

in  generate
