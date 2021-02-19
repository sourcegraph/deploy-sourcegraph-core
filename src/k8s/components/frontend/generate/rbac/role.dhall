let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/Role =
      ../../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.Role.dhall

let Kubernetes/PolicyRule =
      ../../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.PolicyRule.dhall

let Configuration/Internal/Role = ../../configuration/internal/rbac/role.dhall

let Fixtures/frontend/role = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Role/generate
    : ∀(c : Configuration/Internal/Role) → Kubernetes/Role.Type
    = λ(c : Configuration/Internal/Role) →
        let namespace = c.namespace

        let role =
              Kubernetes/Role::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , labels = Some
                  [ { mapKey = "app", mapValue = "frontend" }
                  , { mapKey = "category", mapValue = "rbac" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "frontend"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "cluster-admin"
                    }
                  ]
                , name = Some "sourcegraph-frontend"
                }
              , rules = Some
                [ Kubernetes/PolicyRule::{
                  , verbs = [ "get", "list", "watch" ]
                  , resources = Some [ "endpoints", "services" ]
                  , apiGroups = Some [ "" ]
                  }
                ]
              }

        in  role

let tc = Fixtures/frontend/role.frontend.Config.role

let Test/namespace/none =
        assert
      :   (Role/generate (tc with namespace = None Text)).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( Role/generate (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  Role/generate
