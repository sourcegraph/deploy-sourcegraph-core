let Kubernetes/PersistentVolume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let Kubernetes/PersistentVolumeSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeSpec.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Configuration/Internal/PersistentVolume =
      ../configuration/internal/persistentvolume.dhall

let PersistentVolume/generate
    : ∀(c : Configuration/Internal/PersistentVolume) →
        Optional Kubernetes/PersistentVolume.Type
    = λ(c : Configuration/Internal/PersistentVolume) →
        let pv =
              merge
                { Some =
                    λ(s : Kubernetes/PersistentVolumeSpec.Type) →
                      Some
                        Kubernetes/PersistentVolume::{
                        , apiVersion = "v1"
                        , kind = "PersistentVolume"
                        , metadata = Kubernetes/ObjectMeta::{
                          , labels = Some
                              ( toMap
                                  { deploy = "sourcegraph", disk = "grafana" }
                              )
                          , name = Some "grafana"
                          }
                        , spec = Some s
                        }
                , None = None Kubernetes/PersistentVolume.Type
                }
                c.spec

        in  pv

in  PersistentVolume/generate
