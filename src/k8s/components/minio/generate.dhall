let Generate/Deployment = ./generate/deployment.dhall

let Generate/Service = ./generate/service.dhall

let Generate/PersistentVolumeClaim = ./generate/persistentVolumeClaim.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Generate/Deployment config.Deployment

        let service = Generate/Service config.Service

        let volume = Generate/PersistentVolumeClaim config.PersistentVolumeClaim

        in  { Deployment.minio = deployment
            , Service.minio = service
            , PersistentVolumeClaim.minio = volume
            }

in  generate
