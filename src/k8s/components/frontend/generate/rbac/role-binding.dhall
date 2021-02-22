let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/RoleBinding =
      ../../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.RoleBinding.dhall

let Kubernetes/RoleRef =
      ../../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.RoleRef.dhall

let Kubernetes/Subject =
      ../../../../../deps/k8s/schemas/io.k8s.api.rbac.v1.Subject.dhall

let Configuration/Internal/RoleBinding =
      ../../configuration/internal/rbac/role-binding.dhall

let Fixtures/frontend/roleBinding = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let RoleBinding/generate
    : ∀(c : Configuration/Internal/RoleBinding) → Kubernetes/RoleBinding.Type
    = λ(c : Configuration/Internal/RoleBinding) →
        let namespace = c.namespace

        let roleBinding =
              Kubernetes/RoleBinding::{
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
              , subjects = Some
                [ Kubernetes/Subject::{
                  , name = "sourcegraph-frontend"
                  , kind = "ServiceAccount"
                  , namespace = c.namespace
                  }
                ]
              , roleRef = Kubernetes/RoleRef::{
                , apiGroup = "rbac.authorization.k8s.io"
                , kind = "Role"
                , name = "sourcegraph-frontend"
                }
              }

        in  roleBinding

let tc = Fixtures/frontend/roleBinding.frontend.Config.roleBinding

let Test/namespace/none =
        assert
      :   ( RoleBinding/generate (tc with namespace = None Text)
          ).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( RoleBinding/generate
              (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  RoleBinding/generate
