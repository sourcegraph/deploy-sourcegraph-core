let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Container/query-runner = ./container/query-runner.dhall

let Configuration/Internal/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let ContainerConfiguration =
      { query-runner : Container/query-runner
      , jaeger : Configuration/Internal/jaeger
      }

let DeploymentConfiguration =
      { namespace : Optional Text
      , Containers : ContainerConfiguration
      , sideCars : List Kubernetes/Container.Type
      }

in  DeploymentConfiguration
