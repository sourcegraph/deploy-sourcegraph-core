let Configuration/Internal/ServiceAccount =
      ../../configuration/internal/rbac/service-account.dhall

let Configuration/Internal/RoleBinding =
      ../../configuration/internal/rbac/role-binding.dhall

let Configuration/Internal/Role = ../../configuration/internal/rbac/role.dhall

let TestConfigServiceAccount
    : Configuration/Internal/ServiceAccount
    = { namespace = None Text }

let TestConfigRoleBinding
    : Configuration/Internal/RoleBinding
    = { namespace = None Text }

let TestConfigRole
    : Configuration/Internal/Role
    = { namespace = None Text }

in  { frontend.Config
      =
      { serviceAccount = TestConfigServiceAccount
      , roleBinding = TestConfigRoleBinding
      , role = TestConfigRole
      }
    }
