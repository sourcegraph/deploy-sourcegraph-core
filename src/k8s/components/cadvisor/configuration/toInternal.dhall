let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let ClusterRole/Internal = ./internal/clusterrole.dhall

let ClusterRoleBinding/Internal = ./internal/clusterrolebinding.dhall

let DaemonSet/Internal = ./internal/daemonset.dhall

let ServiceAccount/Internal = ./internal/serviceaccount.dhall

let PodSecurityPolicy/Internal = ./internal/podsecuritypolicy.dhall

let util = ../../../../util/package.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let simple/cadvisor =
      (../../../../simple/cadvisor/package.dhall).Containers.cadvisor

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Volume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/HostPathVolumeSource =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.HostPathVolumeSource.dhall

let Kubernetes/AllowedHostPath =
      ../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.AllowedHostPath.dhall

let ClusterRole/toInternal
    : ∀(cg : Configuration/global.Type) → ClusterRole/Internal
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let ClusterRoleBinding/toInternal
    : ∀(cg : Configuration/global.Type) → ClusterRoleBinding/Internal
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let DaemonSet/toInternal
    : ∀(cg : Configuration/global.Type) → DaemonSet/Internal
    = λ(cg : Configuration/global.Type) →
        let containers = cg.cadvisor.DaemonSet.Containers

        let containerImage =
              util.Image/manipulate
                cg.Global.ImageManipulations
                containers.cadvisor.image

        let containerResources =
              Configuration/ResourceRequirements/toK8s
                containers.cadvisor.resources

        let containerArgs =
                [ "--store_container_labels=false"
                , "--whitelisted_container_labels=io.kubernetes.container.name,io.kubernetes.pod.name,io.kubernetes.pod.namespace,io.kubernetes.pod.uid"
                ]
              # containers.cadvisor.additionalArgs

        let containerVolumeMounts =
              [ Kubernetes/VolumeMount::{
                , name = "rootfs"
                , mountPath = simple/cadvisor.volumes.rootFs.mountPath
                , readOnly = Some True
                }
              , Kubernetes/VolumeMount::{
                , name = "var-run"
                , mountPath = simple/cadvisor.volumes.var-run.mountPath
                , readOnly = Some True
                }
              , Kubernetes/VolumeMount::{
                , name = "sys"
                , mountPath = simple/cadvisor.volumes.sys.mountPath
                , readOnly = Some True
                }
              , Kubernetes/VolumeMount::{
                , name = "docker"
                , mountPath = simple/cadvisor.volumes.docker.mountPath
                , readOnly = Some True
                }
              , Kubernetes/VolumeMount::{
                , name = "disk"
                , mountPath = simple/cadvisor.volumes.disk.mountPath
                , readOnly = Some True
                }
              ]

        let volumes =
              [ Kubernetes/Volume::{
                , name = "rootfs"
                , hostPath = Some Kubernetes/HostPathVolumeSource::{
                  , path = simple/cadvisor.volumes.rootFs.hostPath
                  }
                }
              , Kubernetes/Volume::{
                , name = "var-run"
                , hostPath = Some Kubernetes/HostPathVolumeSource::{
                  , path = simple/cadvisor.volumes.var-run.hostPath
                  }
                }
              , Kubernetes/Volume::{
                , name = "sys"
                , hostPath = Some Kubernetes/HostPathVolumeSource::{
                  , path = simple/cadvisor.volumes.sys.hostPath
                  }
                }
              , Kubernetes/Volume::{
                , name = "docker"
                , hostPath = Some Kubernetes/HostPathVolumeSource::{
                  , path = simple/cadvisor.volumes.docker.hostPath
                  }
                }
              , Kubernetes/Volume::{
                , name = "disk"
                , hostPath = Some Kubernetes/HostPathVolumeSource::{
                  , path = simple/cadvisor.volumes.disk.hostPath
                  }
                }
              ]

        in  { namespace = cg.Global.namespace
            , image = containerImage
            , args = containerArgs
            , containerResources
            , volumeMounts = containerVolumeMounts
            , volumes
            }

let ServiceAccount/toInternal
    : ∀(cg : Configuration/global.Type) → ServiceAccount/Internal
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let PodSecurityPolicy/toInternal
    : ∀(cg : Configuration/global.Type) → PodSecurityPolicy/Internal
    = λ(cg : Configuration/global.Type) →
        let allowedHostPaths =
              [ Kubernetes/AllowedHostPath::{
                , pathPrefix = Some simple/cadvisor.volumes.rootFs.hostPath
                }
              , Kubernetes/AllowedHostPath::{
                , pathPrefix = Some simple/cadvisor.volumes.var-run.hostPath
                }
              , Kubernetes/AllowedHostPath::{
                , pathPrefix = Some simple/cadvisor.volumes.sys.hostPath
                }
              , Kubernetes/AllowedHostPath::{
                , pathPrefix = Some simple/cadvisor.volumes.docker.hostPath
                }
              , Kubernetes/AllowedHostPath::{
                , pathPrefix = Some simple/cadvisor.volumes.disk.hostPath
                }
              ]

        in  { namespace = cg.Global.namespace, allowedHostPaths }

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { ClusterRole.cadvisor = ClusterRole/toInternal cg
        , ClusterRoleBinding.cadvisor = ClusterRoleBinding/toInternal cg
        , DaemonSet.cadvisor = DaemonSet/toInternal cg
        , ServiceAccount.cadvisor = ServiceAccount/toInternal cg
        , PodSecurityPolicy.cadvisor = PodSecurityPolicy/toInternal cg
        }

in  toInternal
