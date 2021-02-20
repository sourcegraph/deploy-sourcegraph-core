let Configuration/Internal/Service/sourcegraph-frontend =
      ./internal/service/sourcegraph-frontend.dhall

let Configuration/Internal/Service/sourcegraph-frontend-internal =
      ./internal/service/sourcegraph-frontend-internal.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let Configuration/Internal/ServiceAccount =
      ./internal/rbac/service-account.dhall

let Configuration/Internal/Role = ./internal/rbac/role.dhall

let Configuration/Internal/RoleBinding = ./internal/rbac/role-binding.dhall

let Configuration/Internal/Ingress = ./internal/ingress.dhall

let configuration =
      { Deployment :
          { sourcegraph-frontend : Configuration/Internal/Deployment }
      , Service :
          { sourcegraph-frontend :
              Configuration/Internal/Service/sourcegraph-frontend
          , sourcegraph-frontend-internal :
              Configuration/Internal/Service/sourcegraph-frontend-internal
          }
      , Role : Configuration/Internal/Role
      , RoleBinding : Configuration/Internal/RoleBinding
      , ServiceAccount : Configuration/Internal/ServiceAccount
      , Ingress : Configuration/Internal/Ingress
      }

in  configuration
