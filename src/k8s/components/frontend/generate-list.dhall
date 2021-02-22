let Generate/Shape = ./generate.dhall

let Configuration/global = ../../configuration/global.dhall

let Kubernetes/Union = ../../union.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let shape = Generate/Shape cg

        in  [ Kubernetes/Union.Deployment shape.Deployment.sourcegraph-frontend
            , Kubernetes/Union.Service shape.Service.sourcegraph-frontend
            , Kubernetes/Union.Service
                shape.Service.sourcegraph-frontend-internal
            , Kubernetes/Union.Role shape.Role.sourcegraph-frontend
            , Kubernetes/Union.RoleBinding
                shape.RoleBinding.sourcegraph-frontend
            , Kubernetes/Union.ServiceAccount
                shape.ServiceAccount.sourcegraph-frontend
            , Kubernetes/Union.Ingress shape.Ingress.sourcegraph-frontend
            ]

in  generate-list
