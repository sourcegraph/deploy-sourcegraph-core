let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../containers/fixtures.dhall

let Fixtures/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/fixtures.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let configuration/volumes = ../../configuration/volumes/volumes.dhall

let TestConfig
    : Configuration/Internal/Deployment
    = { Containers =
        { searcher = Fixtures/containers.searcher.Config
        , jaeger = Fixtures/jaeger.Config
        }
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      , replicas = Fixtures.Replicas
      , volumes = configuration/volumes::{=}
      }

in  { searcher.Config = TestConfig }
