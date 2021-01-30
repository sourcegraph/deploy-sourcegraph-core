let Kubernetes/SecurityContext =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures = ../../../../util/test-fixtures/package.dhall

let Configuration/Internal/Container/zoekt-indexserver =
      ../../configuration/internal/container/zoekt-indexserver.dhall

let Configuration/Internal/Container/zoekt-webserver =
      ../../configuration/internal/container/zoekt-webserver.dhall

let TestConfigIndexServer
    : Configuration/Internal/Container/zoekt-indexserver
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = None (List Kubernetes/EnvVar.Type)
      , volumeMounts = None (List Kubernetes/VolumeMount.Type)
      }

let TestConfigWebServer
    : Configuration/Internal/Container/zoekt-webserver
    = { securityContext = None Kubernetes/SecurityContext.Type
      , resources = None Kubernetes/ResourceRequirements.Type
      , image = Fixtures.Image.Base
      , envVars = None (List Kubernetes/EnvVar.Type)
      , volumeMounts = None (List Kubernetes/VolumeMount.Type)
      }

in  { indexed-search =
      { ConfigIndexServer = TestConfigIndexServer
      , ConfigWebServer = TestConfigWebServer
      }
    }
