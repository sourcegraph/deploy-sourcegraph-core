let Generate/Deployment = ./generate/deployment/deployment.dhall

let Generate/Service = ./generate/service/service.dhall

let Configuration/global = ../../configuration/global.dhall

let Kubernetes/Union = ../../union.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Generate/Deployment config.Deployment.query-runner

        let service = Generate/Service config.Service.query-runner

        in  [ Kubernetes/Union.Deployment deployment
            , Kubernetes/Union.Service service
            ]

in  generate-list
