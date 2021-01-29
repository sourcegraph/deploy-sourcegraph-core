let Configuration/Internal/ServiceAccount =
      ../configuration/internal/serviceaccount.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServiceAccount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let generate
    : ∀(c : Configuration/Internal/ServiceAccount) →
        Kubernetes/ServiceAccount.Type
    = λ(c : Configuration/Internal/ServiceAccount) →
        Kubernetes/ServiceAccount::{
        , metadata = Kubernetes/ObjectMeta::{
          , namespace = c.namespace
          , labels = Some
              ( toMap
                  { sourcegraph-resource-requires = "cluster-admin"
                  , category = "rbac"
                  , app = "cadvisor"
                  , `app.kubernetes.io/component` = "cadvisor"
                  , deploy = "sourcegraph"
                  }
              )
          , name = Some "cadvisor"
          }
        }

in  generate
