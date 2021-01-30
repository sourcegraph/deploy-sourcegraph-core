let Container/jaeger = ./container/jaeger.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let ContainerConfiguration = { jaeger : Container/jaeger }

in  { namespace : Optional Text
    , Containers : ContainerConfiguration
    , sideCars : List Kubernetes/Container.Type
    }
