let Kubernetes/ClusterRole =
      ../../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRole.dhall

let Kubernetes/ClusterRoleBinding =
      ../../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall

let Kubernetes/DaemonSet =
      ../../../deps/k8s/schemas/io.k8s.api.apps.v1.DaemonSet.dhall

let Kubernetes/ServiceAccount =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let Kubernetes/PodSecurityPolicy =
      ../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.PodSecurityPolicy.dhall

let shape =
      { ClusterRole : { cadvisor : Kubernetes/ClusterRole.Type }
      , ClusterRoleBinding : { cadvisor : Kubernetes/ClusterRoleBinding.Type }
      , DaemonSet : { cadvisor : Kubernetes/DaemonSet.Type }
      , ServiceAccount : { cadvisor : Kubernetes/ServiceAccount.Type }
      , PodSecurityPolicy : { cadvisor : Kubernetes/PodSecurityPolicy.Type }
      }

in  shape
