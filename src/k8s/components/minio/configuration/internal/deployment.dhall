let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let util = ../../../../../util/package.dhall

let Image = util.Image

let Container/minio =
      { securityContext : Optional Kubernetes/SecurityContext.Type
      , resources : Optional Kubernetes/ResourceRequirements.Type
      , image : Image.Type
      , volumeMounts : Optional (List Kubernetes/VolumeMount.Type)
      , envVars : Optional (List Kubernetes/EnvVar.Type)
      }

let config =
      { namespace : Optional Text
      , containers : { minio : Container/minio }
      , volumes : { minio-data : { claimName : Text } }
      }

in  config
