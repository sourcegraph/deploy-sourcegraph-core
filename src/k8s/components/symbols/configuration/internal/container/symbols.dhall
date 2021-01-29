let Kubernetes/SecurityContext =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let util = ../../../../../../util/package.dhall

let Image = util.Image

let Container/symbols =
      { securityContext : Optional Kubernetes/SecurityContext.Type
      , resources : Optional Kubernetes/ResourceRequirements.Type
      , image : Image.Type
      , envVars : Optional (List Kubernetes/EnvVar.Type)
      , volumeMounts : Optional (List Kubernetes/VolumeMount.Type)
      }

in  Container/symbols
