let Kubernetes/SecurityContext =
      ../../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let util = ../../../../../../../util/package.dhall

let Image = util.Image

let Container/jaeger =
      { resources : Optional Kubernetes/ResourceRequirements.Type
      , securityContext : Optional Kubernetes/SecurityContext.Type
      , image : Image.Type
      }

in  Container/jaeger
