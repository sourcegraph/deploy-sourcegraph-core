let Configuration/global = ../../configuration/global.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let shape = ./shape.dhall

let Deployment/generate = ./generate/deployment.dhall

let Service/generate = ./generate/service.dhall

let ConfigMap/generate = ./generate/configmap.dhall

let PersistentVolumeClaim/generate = ./generate/persistentVolumeClaim.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let c = Configuration/toInternal cg

        in  { Deployment.pgsql = Deployment/generate c.Deployment
            , Service.pgsql = Service/generate c.Service
            , ConfigMap.pgsql-conf = ConfigMap/generate c.ConfigMap
            , PersistentVolumeClaim.pgsql
              = PersistentVolumeClaim/generate c.PersistentVolumeClaim
            }

in  generate
