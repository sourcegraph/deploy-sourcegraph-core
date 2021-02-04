let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let shape =
      { Deployment :
          { redis-cache : Kubernetes/Deployment.Type
          , redis-store : Kubernetes/Deployment.Type
          }
      , Service :
          { redis-cache : Kubernetes/Service.Type
          , redis-store : Kubernetes/Service.Type
          }
      , PersistentVolumeClaim :
          { redis-cache : Kubernetes/PersistentVolumeClaim.Type
          , redis-store : Kubernetes/PersistentVolumeClaim.Type
          }
      }

in  shape
