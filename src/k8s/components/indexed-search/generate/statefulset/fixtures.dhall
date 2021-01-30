let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Fixtures/containers = ../container/fixtures.dhall

let Fixtures/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/fixtures.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let TestConfig
    : Configuration/Internal/Deployment
    = { Containers =
        { symbols = Fixtures/containers.symbols.Config
        , jaeger = Fixtures/jaeger.Config
        }
      , namespace = None Text
      , replicas = 1
      , volumes.cache-ssd = Fixtures/global.Volumes.NFS
      , sideCars = [] : List Kubernetes/Container.Type
      }

in  { symbols =
      { Config = TestConfig
      , Volumes.expected = [ Fixtures/global.Volumes.NFS ]
      }
    }
