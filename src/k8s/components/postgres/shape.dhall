let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ConfigMap =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let shape =
      { Deployment : { pgsql : Kubernetes/Deployment.Type }
      , Service : { pgsql : Kubernetes/Service.Type }
      , ConfigMap : { pgsql-conf : Kubernetes/ConfigMap.Type }
      , PersistentVolumeClaim :
          { pgsql : Kubernetes/PersistentVolumeClaim.Type }
      }

in  shape
