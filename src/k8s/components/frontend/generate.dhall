let Generate/Deployment = ./generate/deployment/sourcegraph-frontend.dhall

let Generate/Service/Frontend = ./generate/service/sourcegraph-frontend.dhall

let Generate/Service/FrontendInternal =
      ./generate/service/sourcegraph-frontend-internal.dhall

let Generate/RBAC/Role = ./generate/rbac/role.dhall

let Generate/RBAC/RoleBinding = ./generate/rbac/role-binding.dhall

let Generate/RBAC/ServiceAccount = ./generate/rbac/service-account.dhall

let Generate/Ingress = ./generate/ingress/ingress.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment =
              Generate/Deployment config.Deployment.sourcegraph-frontend

        let service/sourcegraph-frontend =
              Generate/Service/Frontend config.Service.sourcegraph-frontend

        let service/sourcegraph-frontend-internal =
              Generate/Service/FrontendInternal
                config.Service.sourcegraph-frontend-internal

        let role = Generate/RBAC/Role config.Role

        let roleBinding = Generate/RBAC/RoleBinding config.RoleBinding

        let serviceAccount = Generate/RBAC/ServiceAccount config.ServiceAccount

        let ingress = Generate/Ingress config.Ingress

        in  { Deployment.sourcegraph-frontend = deployment
            , Service =
              { sourcegraph-frontend = service/sourcegraph-frontend
              , sourcegraph-frontend-internal =
                  service/sourcegraph-frontend-internal
              }
            , Ingress.sourcegraph-frontend = ingress
            , Role.sourcegraph-frontend = role
            , RoleBinding.sourcegraph-frontend = roleBinding
            , ServiceAccount.sourcegraph-frontend = serviceAccount
            }

in  generate
