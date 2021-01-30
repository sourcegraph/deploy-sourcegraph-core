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
