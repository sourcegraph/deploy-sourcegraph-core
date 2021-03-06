let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/syntect-server =
      ../../configuration/internal/container/syntect-server.dhall

let TestConfig
    : Configuration/Internal/Container/syntect-server
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = None (List Kubernetes/EnvVar.Type)
      , volumeMounts = None (List Kubernetes/VolumeMount.Type)
      }

in  { syntect-server =
      { Config = TestConfig
      , Environment.input
        = Some
        [ Fixtures.Environment.Secret, Fixtures.Environment.Gus ]
      , Environment.noneInput = None (List Kubernetes/EnvVar.Type)
      , Environment.expected
        = Some
        [ Fixtures.Environment.Secret, Fixtures.Environment.Gus ]
      , Environment.noneExpected = None (List Kubernetes/EnvVar.Type)
      , VolumeMounts.input
        = Some
        [ Fixtures.VolumeMounts.MaybeNot, Fixtures.VolumeMounts.Lights ]
      , VolumeMounts.expected
        = Some
        [ Fixtures.VolumeMounts.MaybeNot, Fixtures.VolumeMounts.Lights ]
      , VolumeMounts.noneInput = None (List Kubernetes/VolumeMount.Type)
      , VolumeMounts.noneExpected = None (List Kubernetes/VolumeMount.Type)
      }
    }
