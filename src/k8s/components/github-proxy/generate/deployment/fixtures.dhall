let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../containers/fixtures.dhall

let Fixtures/jaeger =
      ../../../shared/jaeger/configuration/internal/jaeger/fixtures.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let TestConfig
    : Configuration/Internal/Deployment
    = { Containers =
        { github-proxy = Fixtures/containers.github-proxy.Config
        , jaeger = Fixtures/jaeger.Config
        }
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      }

in  { github-proxy.Config = TestConfig }
