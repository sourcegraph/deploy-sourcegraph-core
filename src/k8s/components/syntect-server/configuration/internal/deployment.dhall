let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Container/syntect-server = ./container/syntect-server.dhall

let Configuration/Internal/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let ContainerConfiguration =
      { syntect-server : Container/syntect-server
      , jaeger : Configuration/Internal/jaeger
      }

let DeploymentConfiguration =
      { namespace : Optional Text
      , Containers : ContainerConfiguration
      , sideCars : List Kubernetes/Container.Type
      , volumes : List Kubernetes/Volume.Type
      }

in  DeploymentConfiguration
