let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/jaeger =
      ../../configuration/internal/container/jaeger.dhall

let TestConfig
    : Configuration/Internal/Container/jaeger
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = Some ([] : List Kubernetes/EnvVar.Type)
      , volumeMounts = Some ([] : List Kubernetes/VolumeMount.Type)
      }

in  { jaeger =
      { Config = TestConfig
      , Environment.expected = [ Fixtures.Environment.Secret ]
      , VolumeMounts =
        { emptyExpected = None (List Kubernetes/VolumeMount.Type)
        , expected = [ Fixtures.VolumeMounts.Lights ]
        }
      }
    }
