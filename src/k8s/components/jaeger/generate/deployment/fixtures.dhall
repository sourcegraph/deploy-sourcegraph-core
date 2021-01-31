let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Fixtures/containers = ../container/fixtures.dhall

let Configuration/Internal/Deployment =
      ../../configuration/internal/deployment.dhall

let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let TestConfig
    : Configuration/Internal/Deployment
    = { Containers.jaeger = Fixtures/containers.jaeger.Config
      , namespace = None Text
      , sideCars = [] : List Kubernetes/Container.Type
      , additionalVolumes = [] : List Kubernetes/Volume.Type
      }

in  { jaeger.Config = TestConfig }
