let Configuration/Internal/Service/IndexedSearch =
      ../../configuration/internal/service/indexed-search.dhall

let Configuration/Internal/Service/IndexedSearchIndexer =
      ../../configuration/internal/service/indexed-search-indexer.dhall

let TestConfigIndexedSearch
    : Configuration/Internal/Service/IndexedSearch
    = { namespace = None Text }

let TestConfigIndexedSearchIndexer
    : Configuration/Internal/Service/IndexedSearchIndexer
    = { namespace = None Text }

in  { indexed-search =
      { ConfigIndexedSearch = TestConfigIndexedSearch
      , ConfigIndexedSearchIndexer = TestConfigIndexedSearchIndexer
      }
    }
