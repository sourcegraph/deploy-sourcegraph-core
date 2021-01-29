let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let util = ../../../../../util/package.dhall

let config =
      { namespace : Optional Text
      , image : util.Image.Type
      , args : List Text
      , containerResources : Optional Kubernetes/ResourceRequirements.Type
      , volumeMounts : List Kubernetes/VolumeMount.Type
      , volumes : List Kubernetes/Volume.Type
      }

in  config
