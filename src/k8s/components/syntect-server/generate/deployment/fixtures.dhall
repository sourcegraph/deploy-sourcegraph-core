let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../containers/fixtures.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let TestConfig
    : Configuration/Internal/Deployment
    = { Containers.syntect-server = Fixtures/containers.syntect-server.Config
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      , volumes = [] : List Kubernetes/Volume.Type
      }

in  { syntect-server =
      { Config = TestConfig
      , Volumes =
        { input = [ Fixtures/global.Volumes.NFS, Fixtures/global.Volumes.NFS ]
        , emptyInput = None (List Kubernetes/Volume.Type)
        , expected = Some
          [ Fixtures/global.Volumes.NFS, Fixtures/global.Volumes.NFS ]
        , emptyExpected = None (List Kubernetes/Volume.Type)
        }
      , Sidecars =
        { input = [ Fixtures/global.SideCars.Baz, Fixtures/global.SideCars.Foo ]
        , emptyInput = [] : List Kubernetes/Container.Type
        , expected =
          [ Fixtures/global.SideCars.Baz, Fixtures/global.SideCars.Foo ]
        , emptyExpected = [] : List Kubernetes/Container.Type
        }
      }
    }
