let List/map =
      https://prelude.dhall-lang.org/v18.0.0/List/map.dhall sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let Kubernetes/PersistentVolume =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let Kubernetes/Union = ../union.dhall

let pvToUnion
    : Kubernetes/PersistentVolume.Type → Kubernetes/Union
    = λ(x : Kubernetes/PersistentVolume.Type) →
        Kubernetes/Union.PersistentVolume x

let pvsToUnionList
    : Optional (List Kubernetes/PersistentVolume.Type) → List Kubernetes/Union
    = λ(oxs : Optional (List Kubernetes/PersistentVolume.Type)) →
        let pvs =
              merge
                { Some =
                    λ(xs : List Kubernetes/PersistentVolume.Type) →
                      List/map
                        Kubernetes/PersistentVolume.Type
                        Kubernetes/Union
                        pvToUnion
                        xs
                , None = [] : List Kubernetes/Union
                }
                oxs

        in  pvs

in  pvsToUnionList
