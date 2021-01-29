let Configuration/Internal/ClusterRoleBinding =
      ../configuration/internal/clusterrolebinding.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ClusterRoleBinding =
      ../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall

let Kubernetes/Subject =
      ../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.Subject.dhall

let generate
    : ∀(c : Configuration/Internal/ClusterRoleBinding) →
        Kubernetes/ClusterRoleBinding.Type
    = λ(c : Configuration/Internal/ClusterRoleBinding) →
        Kubernetes/ClusterRoleBinding::{
        , apiVersion = "rbac.authorization.k8s.io/v1"
        , metadata = Kubernetes/ObjectMeta::{
          , name = Some "cadvisor"
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
          }
        , roleRef =
          { apiGroup = "rbac.authorization.k8s.io"
          , kind = "ClusterRole"
          , name = "cadvisor"
          }
        , subjects = Some
          [ Kubernetes/Subject::{ kind = "ServiceAccount", name = "cadvisor" } ]
        }

in  generate
