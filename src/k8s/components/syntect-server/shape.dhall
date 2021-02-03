let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let shape =
      { Deployment : { syntect-server : Kubernetes/Deployment.Type }
      , Service : { syntect-server : Kubernetes/Service.Type }
      }

in  shape
