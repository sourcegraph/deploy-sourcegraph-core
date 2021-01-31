let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../container/fixtures.dhall

let Configuration/Internal/StatefulSet =
      ../../configuration/internal/statefulset.dhall

let TestConfig
    : Configuration/Internal/StatefulSet
    = { Containers =
        { zoekt-indexserver =
            Fixtures/containers.indexed-search.ConfigIndexServer
        , zoekt-webserver = Fixtures/containers.indexed-search.ConfigWebServer
        }
      , namespace = None Text
      , replicas = 1
      , sideCars = [] : List Kubernetes/Container.Type
      }

in  { indexed-search.Config = TestConfig }
