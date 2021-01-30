let Generate/StatefulSet = ./generate/statefulset/statefulset.dhall

let Generate/Service/IndexedSearch = ./generate/service/indexed-search.dhall

let Generate/Service/IndexedSearchIndexer =
      ./generate/service/indexed-search-indexer.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let PersistentVolumes/generate = ./generate/persistentvolumes.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let statefulset = Generate/StatefulSet config.StatefulSet.indexed-search

        let service/indexed-search =
              Generate/Service/IndexedSearch config.Service.indexed-search

        let service/indexed-search-indexer =
              Generate/Service/IndexedSearchIndexer
                config.Service.indexed-search-indexer

        let persistentvolumes =
              PersistentVolumes/generate config.persistentvolumes

        in  { StatefulSet.indexed-search = statefulset
            , Service =
              { indexed-search = service/indexed-search
              , indexed-search-indexer = service/indexed-search-indexer
              }
            , PersistentVolumes = persistentvolumes
            }

in  generate
