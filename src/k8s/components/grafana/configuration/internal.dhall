let Internal/Service = ./internal/service.dhall

let Internal/StatefulSet = ./internal/statefulset.dhall

let Internal/PersistentVolume = ./internal/persistentvolume.dhall

let Internal/ServiceAccount = ./internal/serviceaccount.dhall

let Internal/ConfigMap = ./internal/configmap.dhall

let configuration =
      { Service : { grafana : Internal/Service }
      , StatefulSet : { grafana : Internal/StatefulSet }
      , PersistentVolume : { grafana : Internal/PersistentVolume }
      , ServiceAccount : { grafana : Internal/ServiceAccount }
      , ConfigMap : { grafana : Internal/ConfigMap }
      }

in  configuration
