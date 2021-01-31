let Kubernetes/PersistentVolume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let Generate/Service = ./generate/service.dhall

let Generate/StatefulSet = ./generate/statefulset.dhall

let Generate/ConfigMap = ./generate/configmap.dhall

let Generate/ServiceAccount = ./generate/serviceaccount.dhall

let Generate/PersistentVolume = ./generate/persistentvolume.dhall

let Configuration/global = ../../configuration/global.dhall

let Kubernetes/Union = ../../union.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let pv = Generate/PersistentVolume config.PersistentVolume.grafana

        let pvs =
              merge
                { Some =
                    λ(p : Kubernetes/PersistentVolume.Type) →
                      [ Kubernetes/Union.PersistentVolume p ]
                , None = [] : List Kubernetes/Union
                }
                pv

        in    [ Kubernetes/Union.Service
                  (Generate/Service config.Service.grafana)
              , Kubernetes/Union.StatefulSet
                  (Generate/StatefulSet config.StatefulSet.grafana)
              , Kubernetes/Union.ConfigMap
                  (Generate/ConfigMap config.ConfigMap.grafana)
              , Kubernetes/Union.ServiceAccount
                  (Generate/ServiceAccount config.ServiceAccount.grafana)
              ]
            # pvs

in  generate-list
