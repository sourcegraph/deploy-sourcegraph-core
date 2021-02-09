let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ConfigMap =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let shape =
      { Deployment : { codeintel-db : Kubernetes/Deployment.Type }
      , Service : { codeintel-db : Kubernetes/Service.Type }
      , ConfigMap : { codeintel-db-conf : Kubernetes/ConfigMap.Type }
      , PersistentVolumeClaim :
          { codeintel-db : Kubernetes/PersistentVolumeClaim.Type }
      }

in  shape
