let Container/exporter = ./containers/exporter/exporter.dhall

let Container/init = ./containers/init.dhall

let Container/pgsql = ./containers/pgsql.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Containers =
      { correct-data-dir-permissions : Container/init
      , pgsql : Container/pgsql
      , pgsql-exporter : Container/exporter
      }

let volumes = { disk : { persistentVolumeClaim : { claimName : Text } } }

let Configuration =
      { namespace : Optional Text
      , Containers : Containers
      , Volumes : volumes
      , podSecurityContext : Optional Kubernetes/PodSecurityContext.Type
      , sideCars : List Kubernetes/Container.Type
      , additionalVolumes : List Kubernetes/Volume.Type
      }

in  Configuration
