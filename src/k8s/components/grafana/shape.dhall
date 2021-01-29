let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceAccount =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let Kubernetes/StatefulSet =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/ConfigMap =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let Kubernetes/PersistentVolume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let shape =
      { Service : { grafana : Kubernetes/Service.Type }
      , StatefulSet : { grafana : Kubernetes/StatefulSet.Type }
      , ServiceAccount : { grafana : Kubernetes/ServiceAccount.Type }
      , ConfigMap : { grafana : Kubernetes/ConfigMap.Type }
      , PersistentVolume :
          { grafana : Optional Kubernetes/PersistentVolume.Type }
      }

in  shape
