let Fixtures/global = ../../../../../../util/test-fixtures/package.dhall

let Kubernetes/ResourceRequirements =
      ../../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/SecurityContext =
      ../../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Configuration/Container/jaeger = ./jaeger.dhall

let TestConfig
    : Configuration/Container/jaeger
    = { resources = None Kubernetes/ResourceRequirements.Type
      , securityContext = None Kubernetes/SecurityContext.Type
      , image = Fixtures/global.Image.Base
      }

in  { Config = TestConfig }
