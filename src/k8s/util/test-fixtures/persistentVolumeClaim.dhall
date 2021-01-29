let Kubernetes/LabelSelector =
      ../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let selector =
      Kubernetes/LabelSelector::{
      , matchLabels = Some [ { mapKey = "LaBeLKey", mapValue = "LaBeLValUe" } ]
      }

in  { selector }
