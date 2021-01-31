let List/map =
      https://prelude.dhall-lang.org/v18.0.0/List/map.dhall sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let Kubernetes/PersistentVolume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolume.dhall

let Configuration/global = ../../configuration/global.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let Kubernetes/Union = ../../union.dhall

let Service/generate = ./generate/service.dhall

let StatefulSet/generate = ./generate/statefulset.dhall

let PersistentVolumes/generate = ./generate/persistentvolumes.dhall

let pvsToUnionList = ../../util/persistentvolumes.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let c = Configuration/toInternal cg

        let statefulSet = StatefulSet/generate c.statefulset

        let service = Service/generate c.service

        let persistentvolumes = PersistentVolumes/generate c.persistentvolumes

        let pvs = pvsToUnionList persistentvolumes

        in    [ Kubernetes/Union.StatefulSet statefulSet
              , Kubernetes/Union.Service service
              ]
            # pvs

in  generate-list
