let Configuration/global = ../../configuration/global.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let shape = ./shape.dhall

let Service/generate = ./generate/service.dhall

let StatefulSet/generate = ./generate/statefulset.dhall

let PersistentVolumes/generate = ./generate/persistentvolumes.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let c = Configuration/toInternal cg

        let statefulSet = StatefulSet/generate c.statefulset

        let service = Service/generate c.service

        let persistentvolumes = PersistentVolumes/generate c.persistentvolumes

        in    { StatefulSet.gitserver = statefulSet }
            ∧ { Service.gitserver = service }
            ∧ { PersistentVolumes = persistentvolumes }

in  generate
