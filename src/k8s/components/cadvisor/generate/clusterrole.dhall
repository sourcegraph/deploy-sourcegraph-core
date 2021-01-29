let Configuration/Internal/ClusterRole =
      ../configuration/internal/clusterrole.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ClusterRole =
      ../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRole.dhall

let Kubernetes/PolicyRule =
      ../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.PolicyRule.dhall

let generate
    : ∀(c : Configuration/Internal/ClusterRole) → Kubernetes/ClusterRole.Type
    = λ(c : Configuration/Internal/ClusterRole) →
        Kubernetes/ClusterRole::{
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
        , rules = Some
          [ Kubernetes/PolicyRule::{
            , apiGroups = Some [ "policy" ]
            , resources = Some [ "podsecuritypolicies" ]
            , verbs = [ "use" ]
            , resourceNames = Some [ "cadvisor" ]
            }
          ]
        }

in  generate
