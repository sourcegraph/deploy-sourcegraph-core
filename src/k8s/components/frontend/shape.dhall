let Kubernetes/Deployment =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/Service =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/Ingress =
      ../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.Ingress.dhall

let Kubernetes/Role = ../../../deps/k8s/schemas/io.k8s.api.rbac.v1.Role.dhall

let Kubernetes/RoleBinding =
      ../../../deps/k8s/schemas/io.k8s.api.rbac.v1.RoleBinding.dhall

let Kubernetes/ServiceAccount =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let shape =
      { Deployment : { sourcegraph-frontend : Kubernetes/Deployment.Type }
      , Service :
          { sourcegraph-frontend : Kubernetes/Service.Type
          , sourcegraph-frontend-internal : Kubernetes/Service.Type
          }
      , Ingress : { sourcegraph-frontend : Kubernetes/Ingress.Type }
      , Role : { sourcegraph-frontend : Kubernetes/Role.Type }
      , RoleBinding : { sourcegraph-frontend : Kubernetes/RoleBinding.Type }
      , ServiceAccount :
          { sourcegraph-frontend : Kubernetes/ServiceAccount.Type }
      }

in  shape
