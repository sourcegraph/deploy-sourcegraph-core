let Configuration/Internal/PodSecurityPolicy =
      ../configuration/internal/podsecuritypolicy.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/PodSecurityPolicy =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.PodSecurityPolicy.dhall

let Kubernetes/PodSecurityPolicySpec =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.PodSecurityPolicySpec.dhall

let Kubernetes/FSGroupStrategyOptions =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.FSGroupStrategyOptions.dhall

let Kubernetes/SupplementalGroupsStrategyOptions =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.SupplementalGroupsStrategyOptions.dhall

let Kubernetes/RunAsUserStrategyOptions =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.RunAsUserStrategyOptions.dhall

let Kubernetes/SELinuxStrategyOptions =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.SELinuxStrategyOptions.dhall

let generate
    : ∀(c : Configuration/Internal/PodSecurityPolicy) →
        Kubernetes/PodSecurityPolicy.Type
    = λ(c : Configuration/Internal/PodSecurityPolicy) →
        Kubernetes/PodSecurityPolicy::{
        , apiVersion = "policy/v1beta1"
        , metadata = Kubernetes/ObjectMeta::{
          , name = Some "cadvisor"
          , namespace = c.namespace
          , labels = Some
              ( toMap
                  { sourcegraph-resource-requires = "cluster-admin"
                  , app = "cadvisor"
                  , `app.kubernetes.io/component` = "cadvisor"
                  , deploy = "sourcegraph"
                  }
              )
          }
        , spec = Some Kubernetes/PodSecurityPolicySpec::{
          , seLinux = Kubernetes/SELinuxStrategyOptions::{ rule = "RunAsAny" }
          , supplementalGroups = Kubernetes/SupplementalGroupsStrategyOptions::{
            , rule = Some "RunAsAny"
            }
          , runAsUser = Kubernetes/RunAsUserStrategyOptions::{
            , rule = "RunAsAny"
            }
          , fsGroup = Kubernetes/FSGroupStrategyOptions::{
            , rule = Some "RunAsAny"
            }
          , volumes = Some [ "*" ]
          , allowedHostPaths = Some c.allowedHostPaths
          }
        }

in  generate
