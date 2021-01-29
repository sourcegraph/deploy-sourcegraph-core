let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let pvc =
      { name : Text
      , namespace : Optional Text
      , storageClassName : Optional Text
      , resources : Optional Kubernetes/ResourceRequirements.Type
      }

in  pvc
