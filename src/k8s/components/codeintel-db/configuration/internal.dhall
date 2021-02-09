let Service = ./internal/service.dhall

let Deployment = ./internal/deployment.dhall

let PersistentVolumesClaim = ./internal/persistentVolumeClaim.dhall

let ConfigMap = ./internal/configmap.dhall

let configuration =
      { Deployment : Deployment
      , Service : Service
      , PersistentVolumeClaim : PersistentVolumesClaim
      , ConfigMap : ConfigMap
      }

in  configuration
