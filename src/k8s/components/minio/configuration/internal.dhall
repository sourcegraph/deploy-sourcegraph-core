let Service = ./internal/service.dhall

let Deployment = ./internal/deployment.dhall

let PersistentVolumesClaim = ./internal/persistentVolumeClaim.dhall

let configuration =
      { Deployment : Deployment
      , Service : Service
      , PersistentVolumeClaim : PersistentVolumesClaim
      }

in  configuration
