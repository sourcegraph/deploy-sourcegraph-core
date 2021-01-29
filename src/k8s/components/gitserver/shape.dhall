let Kubernetes/StatefulSet =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let shape =
      { StatefulSet : { gitserver : Kubernetes/StatefulSet.Type }
      , Service : { gitserver : Kubernetes/Service.Type }
      , PersistentVolumes : Optional (List Kubernetes/PersistentVolume.Type)
      }

in  shape
