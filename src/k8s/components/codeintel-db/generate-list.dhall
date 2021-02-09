let Configuration/global = ../../configuration/global.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let Kubernetes/Union = ../../union.dhall

let Deployment/generate = ./generate/deployment.dhall

let Service/generate = ./generate/service.dhall

let ConfigMap/generate = ./generate/configmap.dhall

let PersistentVolumeClaim/generate = ./generate/persistentVolumeClaim.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let c = Configuration/toInternal cg

        in  [ Kubernetes/Union.Deployment (Deployment/generate c.Deployment)
            , Kubernetes/Union.Service (Service/generate c.Service)
            , Kubernetes/Union.ConfigMap (ConfigMap/generate c.ConfigMap)
            , Kubernetes/Union.PersistentVolumeClaim
                (PersistentVolumeClaim/generate c.PersistentVolumeClaim)
            ]

in  generate-list
