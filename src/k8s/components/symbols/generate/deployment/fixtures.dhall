let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

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
      , sideCars = [] : List Kubernetes/Container.Type
      , volumes = [] : List Kubernetes/Volume.Type
      }

in  { symbols =
      { Config = TestConfig
      , Volumes.input
        =
        [ Fixtures/global.Volumes.NFS, Fixtures/global.Volumes.NFS ]
      , Volumes.expected
        = Some
        [ Fixtures/global.Volumes.NFS, Fixtures/global.Volumes.NFS ]
      , Volumes.emptyExpected = None (List Kubernetes/Volume.Type)
      , SideCars =
        { input = [ Fixtures/global.SideCars.Baz, Fixtures/global.SideCars.Foo ]
        , emptyInput = [] : List Kubernetes/Container.Type
        , expected =
          [ Fixtures/global.SideCars.Baz, Fixtures/global.SideCars.Foo ]
        , emptyExpected = [] : List Kubernetes/Container.Type
        }
      }
    }
