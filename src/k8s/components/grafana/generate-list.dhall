-- let Generate/Deployment = ./generate/deployment.dhall
let Generate/Service = ./generate/service.dhall

let Generate/StatefulSet = ./generate/statefulset.dhall

let Generate/ConfigMap = ./generate/configmap.dhall

let Generate/ServiceAccount = ./generate/serviceaccount.dhall

let Configuration/global = ../../configuration/global.dhall

let Kubernetes/Union = ../../union.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        in  [ Kubernetes/Union.Service (Generate/Service config.Service.grafana)
            , Kubernetes/Union.StatefulSet
                (Generate/StatefulSet config.StatefulSet.grafana)
            , Kubernetes/Union.ConfigMap
                (Generate/ConfigMap config.ConfigMap.grafana)
            , Kubernetes/Union.ServiceAccount
                (Generate/ServiceAccount config.ServiceAccount.grafana)
            ]

in  generate-list
