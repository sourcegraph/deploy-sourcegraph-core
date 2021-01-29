let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Container/githubProxy = ./container/github-proxy.dhall

let Configuration/Internal/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let ContainerConfiguration =
      { github-proxy : Container/githubProxy
      , jaeger : Configuration/Internal/jaeger
      }

let DeploymentConfiguration =
      { namespace : Optional Text
      , Containers : ContainerConfiguration
      , sideCars : List Kubernetes/Container.Type
      }

in  DeploymentConfiguration
