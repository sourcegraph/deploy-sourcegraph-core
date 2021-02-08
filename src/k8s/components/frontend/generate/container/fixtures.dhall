let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/frontend =
      ../../configuration/internal/container/frontend.dhall

let environment/toList = ../../configuration/environment/toList.dhall

let TestConfig
    : Configuration/Internal/Container/frontend
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = Some
          ( environment/toList
              { CACHE_DIR = Fixtures.Environment.Secret
              , POD_NAME = Fixtures.Environment.Secret
              }
          )
      , volumeMounts = None (List Kubernetes/VolumeMount.Type)
      }

in  { frontend =
      { Config = TestConfig
      , Environment.expected
        =
        [ Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        ]
      }
    }
