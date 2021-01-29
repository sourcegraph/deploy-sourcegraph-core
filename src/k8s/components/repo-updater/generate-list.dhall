let Configuration/global = ../../configuration/global.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let Kubernetes/Union = ../../union.dhall

let Deployment/generate = ./generate/deployment.dhall

let Service/generate = ./generate/service.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Deployment/generate config.Deployment.repo-updater

        let service = Service/generate config.Service.repo-updater

        in  [ Kubernetes/Union.Deployment deployment
            , Kubernetes/Union.Service service
            ]

in  generate-list
