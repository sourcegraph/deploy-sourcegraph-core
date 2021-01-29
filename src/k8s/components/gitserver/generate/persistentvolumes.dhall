let List/generate =
      https://prelude.dhall-lang.org/v18.0.0/List/generate.dhall sha256:78ff1ad96c08b88a8263eea7bc8381c078225cfcb759c496f792edb5a5e0b1a4

let Kubernetes/PersistentVolume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let Kubernetes/ObjectReference =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectReference.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let PersistentVolumeGeneratorFunctionType =
      ../configuration/persistentVolumeGenerator.dhall

let config = ../configuration/internal/persistentvolumes.dhall

let PersistentVolume/generate
    : ∀(c : config) →
      ∀(f : PersistentVolumeGeneratorFunctionType) →
      ∀(index : Natural) →
        Kubernetes/PersistentVolume.Type
    = λ(c : config) →
      λ(f : PersistentVolumeGeneratorFunctionType) →
      λ(idx : Natural) →
        let labels = toMap { deploy = "sourcegraph", disk = "repos-gitserver" }

        let idxStr = Natural/show idx

        let name = "repos-gitserver-${idxStr}"

        let claimRef =
              Some
                Kubernetes/ObjectReference::{
                , apiVersion = "v1"
                , kind = "PersistentVolumeClaim"
                , name = Some name
                , namespace = c.namespace
                }

        let vspec = f idx

        let vspec = vspec with claimRef = claimRef

        in  Kubernetes/PersistentVolume::{
            , metadata = Kubernetes/ObjectMeta::{
              , labels = Some labels
              , name = Some name
              }
            , spec = Some vspec
            }

let generate
    : ∀(c : config) → Optional (List Kubernetes/PersistentVolume.Type)
    = λ(c : config) →
        let numPVs = c.replicas

        let pvs =
              merge
                { Some =
                    λ(f : PersistentVolumeGeneratorFunctionType) →
                      Some
                        ( List/generate
                            numPVs
                            Kubernetes/PersistentVolume.Type
                            (PersistentVolume/generate c f)
                        )
                , None = None (List Kubernetes/PersistentVolume.Type)
                }
                c.pvg

        in  pvs

in  generate
