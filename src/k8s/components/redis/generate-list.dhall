let Generate = ./generate.dhall

let Configuration/global = ../../configuration/global.dhall

let Kubernetes/Union = ../../union.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let shape = Generate cg

        in  [ Kubernetes/Union.Deployment shape.Deployment.redis-cache
            , Kubernetes/Union.Deployment shape.Deployment.redis-store
            , Kubernetes/Union.Service shape.Service.redis-cache
            , Kubernetes/Union.Service shape.Service.redis-store
            , Kubernetes/Union.PersistentVolumeClaim
                shape.PersistentVolumeClaim.redis-cache
            , Kubernetes/Union.PersistentVolumeClaim
                shape.PersistentVolumeClaim.redis-store
            ]

in  generate-list
