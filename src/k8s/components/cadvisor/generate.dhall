let Generate/ClusterRole = ./generate/clusterrole.dhall

let Generate/ClusterRoleBinding = ./generate/clusterrolebinding.dhall

let Generate/DaemonSet = ./generate/daemonset.dhall

let Generate/PodSecurityPolicy = ./generate/podsecuritypolicy.dhall

let Generate/ServiceAccount = ./generate/serviceaccount.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        in  { ClusterRole.cadvisor
              = Generate/ClusterRole config.ClusterRole.cadvisor
            , ClusterRoleBinding.cadvisor
              = Generate/ClusterRoleBinding config.ClusterRoleBinding.cadvisor
            , DaemonSet.cadvisor = Generate/DaemonSet config.DaemonSet.cadvisor
            , PodSecurityPolicy.cadvisor
              = Generate/PodSecurityPolicy config.PodSecurityPolicy.cadvisor
            , ServiceAccount.cadvisor
              = Generate/ServiceAccount config.ServiceAccount.cadvisor
            }

in  generate
