let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let ContainerConfiguration =
      { zoekt-indexserver : ./container/zoekt-indexserver.dhall
      , zoekt-webserver : ./container/zoekt-webserver.dhall
      }

let StatefulSetConfiguration =
      { namespace : Optional Text
      , replicas : Natural
      , Containers : ContainerConfiguration
      , sideCars : List Kubernetes/Container.Type
      }

in  StatefulSetConfiguration
