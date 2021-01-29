let Kubernetes/ContainerPort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/ObjectFieldSelector =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let util = ../../../../util/package.dhall

let Kubernetes/ResourceRequirements =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Fixtures/global = ../../../util/test-fixtures/package.dhall

let Fixtures/jaeger = ./configuration/internal/jaeger/fixtures.dhall

let Configuration/Internal/jaeger = ./configuration/internal/jaeger/jaeger.dhall

let Jaeger/generate
    : ∀(c : Configuration/Internal/jaeger) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/jaeger) →
        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        in  Kubernetes/Container::{
            , args = Some
              [ "--reporter.grpc.host-port=jaeger-collector:14250"
              , "--reporter.type=grpc"
              ]
            , env = Some
              [ Kubernetes/EnvVar::{
                , name = "POD_NAME"
                , valueFrom = Some Kubernetes/EnvVarSource::{
                  , fieldRef = Some Kubernetes/ObjectFieldSelector::{
                    , apiVersion = Some "v1"
                    , fieldPath = "metadata.name"
                    }
                  }
                }
              ]
            , image = Some image
            , name = "jaeger-agent"
            , ports = Some
              [ Kubernetes/ContainerPort::{
                , containerPort = 5775
                , protocol = Some "UDP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = 5778
                , protocol = Some "TCP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = 6831
                , protocol = Some "UDP"
                }
              , Kubernetes/ContainerPort::{
                , containerPort = 6832
                , protocol = Some "UDP"
                }
              ]
            , securityContext
            , resources
            }

let tc = Fixtures/jaeger.Config

let Test/image/show =
      assert : (Jaeger/generate tc).image ≡ Some Fixtures/global.Image.BaseShow

let Test/resources/some =
        assert
      :   ( Jaeger/generate
              (tc with resources = Fixtures/global.Resources.Expected)
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/resources/none =
        assert
      :   ( Jaeger/generate
              (tc with resources = None Kubernetes/ResourceRequirements.Type)
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/securityContext/some =
        assert
      :   ( Jaeger/generate
              ( tc
                with securityContext = Fixtures/global.SecurityContext.SELinux
              )
          ).securityContext
        ≡ Fixtures/global.SecurityContext.SELinux

let Test/securityContext/none =
        assert
      :   ( Jaeger/generate
              (tc with securityContext = Fixtures/global.SecurityContext.Empty)
          ).securityContext
        ≡ Fixtures/global.SecurityContext.Empty

in  Jaeger/generate
