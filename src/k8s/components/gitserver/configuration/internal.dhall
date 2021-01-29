let Service = ./internal/service.dhall

let StatefulSet = ./internal/statefulset.dhall

let PersistentVolumes = ./internal/persistentvolumes.dhall

let configuration =
      { service : Service
      , statefulset : StatefulSet
      , persistentvolumes : PersistentVolumes
      }

in  configuration
