let Internal/ClusterRole = ./internal/clusterrole.dhall

let Internal/ClusterRoleBinding = ./internal/clusterrolebinding.dhall

let Internal/DaemonSet = ./internal/daemonset.dhall

let Internal/ServiceAccount = ./internal/serviceaccount.dhall

let Internal/PodSecurityPolicy = ./internal/podsecuritypolicy.dhall

let configuration =
      { ClusterRole : { cadvisor : Internal/ClusterRole }
      , ClusterRoleBinding : { cadvisor : Internal/ClusterRoleBinding }
      , DaemonSet : { cadvisor : Internal/DaemonSet }
      , ServiceAccount : { cadvisor : Internal/ServiceAccount }
      , PodSecurityPolicy : { cadvisor : Internal/PodSecurityPolicy }
      }

in  configuration
