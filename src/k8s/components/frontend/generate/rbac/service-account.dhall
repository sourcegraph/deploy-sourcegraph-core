let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ServiceAccount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let Kubernetes/LocalObjectReference =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.LocalObjectReference.dhall

let Configuration/Internal/ServiceAccount =
      ../../configuration/internal/rbac/service-account.dhall

let Fixtures/frontend/serviceAccount = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let ServiceAccount/generate
    : ∀(c : Configuration/Internal/ServiceAccount) →
        Kubernetes/ServiceAccount.Type
    = λ(c : Configuration/Internal/ServiceAccount) →
        let namespace = c.namespace

        let serviceAccount =
              Kubernetes/ServiceAccount::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , labels = Some
                  [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "frontend"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "sourcegraph-frontend"
                }
              , imagePullSecrets = Some
                [ Kubernetes/LocalObjectReference::{
                  , name = Some "docker-registry"
                  }
                ]
              }

        in  serviceAccount

let tc = Fixtures/frontend/serviceAccount.frontend.Config

let Test/namespace/none =
        assert
      :   ( ServiceAccount/generate (tc with namespace = None Text)
          ).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( ServiceAccount/generate
              (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  ServiceAccount/generate
