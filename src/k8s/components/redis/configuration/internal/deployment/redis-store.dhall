let Kubernetes/Container =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/Volume =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let ContainerConfiguration =
      { redis-store : ../container/redis-store.dhall
      , redis-exporter : ../container/redis-exporter.dhall
      }

let DeploymentConfiguration =
      { namespace : Optional Text
      , Containers : ContainerConfiguration
      , sideCars : List Kubernetes/Container.Type
      , additionalVolumes : List Kubernetes/Volume.Type
      }

in  DeploymentConfiguration
