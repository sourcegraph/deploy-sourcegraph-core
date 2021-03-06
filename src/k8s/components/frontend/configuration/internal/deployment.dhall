let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Configuration/Internal/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let ContainerConfiguration =
      { frontend : ./container/frontend.dhall
      , jaeger : Configuration/Internal/jaeger
      }

let DeploymentConfiguration =
      { namespace : Optional Text
      , replicas : Natural
      , Containers : ContainerConfiguration
      , volumes : List Kubernetes/Volume.Type
      , sideCars : List Kubernetes/Container.Type
      }

in  DeploymentConfiguration
