let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/searcher =
      ../../configuration/internal/container/searcher.dhall

let TestConfig
    : Configuration/Internal/Container/searcher
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = Some [ Fixtures.Environment.Secret ]
      , volumeMounts = Some ([] : List Kubernetes/VolumeMount.Type)
      }

in  { searcher =
      { Config = TestConfig
      , Environment.expected = [ Fixtures.Environment.Secret ]
      }
    }
