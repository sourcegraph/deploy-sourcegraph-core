let Configuration/Internal/DaemonSet = ../configuration/internal/daemonset.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/DaemonSet =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DaemonSet.dhall

let Kubernetes/DaemonSetSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DaemonSetSpec.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/LabelSelector =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/PodSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let util = ../../../../util/package.dhall

let simple/cadvisor =
      (../../../../simple/cadvisor/package.dhall).Containers.cadvisor

let generate
    : ∀(c : Configuration/Internal/DaemonSet) → Kubernetes/DaemonSet.Type
    = λ(c : Configuration/Internal/DaemonSet) →
        let port = simple/cadvisor.ports.httpPort

        let cadvisorContainer =
              Kubernetes/Container::{
              , name = "cadvisor"
              , image = Some (util.Image/show c.image)
              , args = Some c.args
              , ports = Some
                [ Kubernetes/ContainerPort::{
                  , name = port.name
                  , containerPort = port.number
                  , protocol = Some "TCP"
                  }
                ]
              , resources = c.containerResources
              , volumeMounts = Some c.volumeMounts
              }

        in  Kubernetes/DaemonSet::{
            , apiVersion = "apps/v1"
            , metadata = Kubernetes/ObjectMeta::{
              , name = Some "cadvisor"
              , namespace = c.namespace
              , annotations = Some
                  ( toMap
                      { `seccomp.security.alpha.kubernetes.io/pod` =
                          "docker/default"
                      , description =
                          "DaemonSet to ensure all nodes run a cAdvisor pod."
                      }
                  )
              , labels = Some
                  ( toMap
                      { sourcegraph-resource-requires = "cluster-admin"
                      , `app.kubernetes.io/component` = "cadvisor"
                      , deploy = "sourcegraph"
                      }
                  )
              }
            , spec = Some Kubernetes/DaemonSetSpec::{
              , selector = Kubernetes/LabelSelector::{
                , matchLabels = Some
                  [ { mapKey = "app", mapValue = "cadvisor" } ]
                }
              , template = Kubernetes/PodTemplateSpec::{
                , metadata = Kubernetes/ObjectMeta::{
                  , annotations = Some
                      ( toMap
                          { `sourcegraph.prometheus/scrape` = "true"
                          , `prometheus.io/port` = "48080"
                          , description =
                              "Collects and exports container metrics."
                          }
                      )
                  , labels = Some
                      (toMap { app = "cadvisor", deploy = "sourcegraph" })
                  }
                , spec = Some Kubernetes/PodSpec::{
                  , containers = [ cadvisorContainer ]
                  , serviceAccountName = Some "cadvisor"
                  , terminationGracePeriodSeconds = Some 30
                  , automountServiceAccountToken = Some False
                  , volumes = Some c.volumes
                  }
                }
              }
            }

in  generate
