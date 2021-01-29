let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let configuration/volumes = ../volumes/volumes.dhall

let Container/searcher = ./container/searcher.dhall

let Configuration/Internal/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let ContainerConfiguration =
      { searcher : Container/searcher, jaeger : Configuration/Internal/jaeger }

let DeploymentConfiguration =
      { namespace : Optional Text
      , replicas : Natural
      , Containers : ContainerConfiguration
      , volumes : configuration/volumes.Type
      , sideCars : List Kubernetes/Container.Type
      }

in  DeploymentConfiguration
