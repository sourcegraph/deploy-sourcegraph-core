let Kubernetes/Container =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let ContainerConfiguration =
      { redis-cache : ../container/redis-cache.dhall
      , redis-exporter : ../container/redis-exporter.dhall
      }

let DeploymentConfiguration =
      { namespace : Optional Text
      , Containers : ContainerConfiguration
      , sideCars : List Kubernetes/Container.Type
      }

in  DeploymentConfiguration
