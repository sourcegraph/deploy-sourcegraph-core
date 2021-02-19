let Configuration/Internal/ServiceAccount =
      ../../configuration/internal/rbac/service-account.dhall

let TestConfig
    : Configuration/Internal/ServiceAccount
    = { namespace = None Text }

in  { frontend.Config = TestConfig }
