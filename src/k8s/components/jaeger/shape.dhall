let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let shape =
      { Service :
          { jaeger-collector : Kubernetes/Service.Type
          , jaeger-query : Kubernetes/Service.Type
          }
      , Deployment : { jaeger : Kubernetes/Deployment.Type }
      }

in  shape
