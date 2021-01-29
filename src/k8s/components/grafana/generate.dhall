-- let Generate/Deployment = ./generate/deployment.dhall
let Generate/Service = ./generate/service.dhall

let Generate/StatefulSet = ./generate/statefulset.dhall

let Generate/PersistentVolume = ./generate/persistentvolume.dhall

let Generate/ConfigMap = ./generate/configmap.dhall

let Generate/ServiceAccount = ./generate/serviceaccount.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        in  { Service.grafana = Generate/Service config.Service.grafana
            , StatefulSet.grafana
              = Generate/StatefulSet config.StatefulSet.grafana
            , ConfigMap.grafana = Generate/ConfigMap config.ConfigMap.grafana
            , ServiceAccount.grafana
              = Generate/ServiceAccount config.ServiceAccount.grafana
            , PersistentVolume.grafana
              = Generate/PersistentVolume config.PersistentVolume.grafana
            }

in  generate
