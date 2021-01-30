let Generate/Shape = ./generate.dhall

let Configuration/global = ../../configuration/global.dhall

let Kubernetes/Union = ../../union.dhall

let pvsToUnionList = ../../util/persistentvolumes.dhall

let generate-list
    : Configuration/global.Type → List Kubernetes/Union
    = λ(cg : Configuration/global.Type) →
        let shape = Generate/Shape cg

        let pvs = pvsToUnionList shape.PersistentVolumes

        in    [ Kubernetes/Union.StatefulSet shape.StatefulSet.indexed-search
              , Kubernetes/Union.Service shape.Service.indexed-search
              , Kubernetes/Union.Service shape.Service.indexed-search-indexer
              ]
            # pvs

in  generate-list
