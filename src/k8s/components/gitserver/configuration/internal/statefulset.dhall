let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let util = ../../../../../util/package.dhall

let Container/gitserver =
      { image : util.Image.Type
      , healthcheck : Kubernetes/Probe.Type
      , rpc/port : Natural
      , securityContext : Optional Kubernetes/SecurityContext.Type
      , containerResources : Optional Kubernetes/ResourceRequirements.Type
      , envVars : Optional (List Kubernetes/EnvVar.Type)
      , volumeMounts : Optional (List Kubernetes/VolumeMount.Type)
      }

let Configuration/Internal/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let ContainerConfiguration =
      { gitserver : Container/gitserver
      , jaeger : Configuration/Internal/jaeger
      }

let config =
      { namespace : Optional Text
      , replicas : Natural
      , podSecurityContext : Optional Kubernetes/PodSecurityContext.Type
      , Containers : ContainerConfiguration
      , storageClassName : Optional Text
      , reposVolumeSize : Text
      , sideCars : List Kubernetes/Container.Type
      }

in  config
