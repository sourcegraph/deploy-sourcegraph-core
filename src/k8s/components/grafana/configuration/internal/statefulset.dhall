let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/PodSecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let util = ../../../../../util/package.dhall

let config =
      { namespace : Optional Text
      , image : util.Image.Type
      , podSecurityContext : Optional Kubernetes/PodSecurityContext.Type
      , containerResources : Optional Kubernetes/ResourceRequirements.Type
      , storageClassName : Optional Text
      , dataVolumeSize : Text
      , envVars : Optional (List Kubernetes/EnvVar.Type)
      , volumeMounts : Optional (List Kubernetes/VolumeMount.Type)
      , sideCars : List Kubernetes/Container.Type
      }

in  config
