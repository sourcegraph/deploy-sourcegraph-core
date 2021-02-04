let Kubernetes/SecurityContext =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let util = ../../../../../../util/package.dhall

let Image = util.Image

let Container/redis-exporter =
      { securityContext : Optional Kubernetes/SecurityContext.Type
      , resources : Optional Kubernetes/ResourceRequirements.Type
      , image : Image.Type
      }

in  Container/redis-exporter
