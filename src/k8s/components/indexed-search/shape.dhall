let Kubernetes/StatefulSet =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let shape =
      { StatefulSet : { indexed-search : Kubernetes/StatefulSet.Type }
      , Service :
          { indexed-search : Kubernetes/Service.Type
          , indexed-search-indexer : Kubernetes/Service.Type
          }
      }

in  shape
