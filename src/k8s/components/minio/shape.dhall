let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let shape =
      { Deployment : { minio : Kubernetes/Deployment.Type }
      , Service : { minio : Kubernetes/Service.Type }
      , PersistentVolumeClaim :
          { minio : Kubernetes/PersistentVolumeClaim.Type }
      }

in  shape
