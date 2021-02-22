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
              { SRC_GIT_SERVERS = Fixtures.Environment.Secret
              , POD_NAME = Fixtures.Environment.Secret
              , CACHE_DIR = Fixtures.Environment.Secret
              , GRAFANA_SERVER_URL = Fixtures.Environment.Secret
              , JAEGER_SERVER_URL = Fixtures.Environment.Secret
              , PROMETHEUS_URL = Fixtures.Environment.Secret
              , PGDATABASE = Fixtures.Environment.Secret
              , PGHOST = Fixtures.Environment.Secret
              , PGPORT = Fixtures.Environment.Secret
              , PGSSLMODE = Fixtures.Environment.Secret
              , PGUSER = Fixtures.Environment.Secret
              , CODEINTEL_PGDATABASE = Fixtures.Environment.Secret
              , CODEINTEL_PGHOST = Fixtures.Environment.Secret
              , CODEINTEL_PGPORT = Fixtures.Environment.Secret
              , CODEINTEL_PGSSLMODE = Fixtures.Environment.Secret
              , CODEINTEL_PGUSER = Fixtures.Environment.Secret
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
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        , Fixtures.Environment.Secret
        ]
      }
    }
