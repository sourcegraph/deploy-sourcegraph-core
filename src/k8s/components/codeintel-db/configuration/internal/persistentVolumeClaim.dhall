let Kubernetes/LabelSelector =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let pvc =
      { namespace : Optional Text
      , name : Text
      , selector : Optional Kubernetes/LabelSelector.Type
      }

in  pvc
