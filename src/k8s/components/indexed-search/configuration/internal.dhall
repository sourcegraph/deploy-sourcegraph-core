let Configuration/Internal/Service/IndexedSearch =
      ./internal/service/indexed-search.dhall

let Configuration/Internal/Service/IndexedSearchIndexer =
      ./internal/service/indexed-search-indexer.dhall

let Configuration/Internal/StatefulSet = ./internal/statefulset.dhall

let PersistentVolumes = ./internal/persistentvolumes.dhall

let configuration =
      { StatefulSet : { indexed-search : Configuration/Internal/StatefulSet }
      , Service :
          { indexed-search : Configuration/Internal/Service/IndexedSearch
          , indexed-search-indexer :
              Configuration/Internal/Service/IndexedSearchIndexer
          }
      , persistentvolumes : PersistentVolumes
      }

in  configuration
