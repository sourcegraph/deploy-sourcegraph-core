let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/containers/query-runner/internal =
      ./internal/container/query-runner.dhall

let Configuration/service/internal = ./internal/service.dhall

let Configuration/containers/jaeger/internal =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Configuration/deployment/internal = ./internal/deployment.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let Fixtures/global = ../../../util/test-fixtures/package.dhall

let Service/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/service/internal
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace in { namespace }

let Test/Service/Namespace/none =
        assert
      :   ( Service/toInternal
              (Fixtures/global.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/Namespace/Some =
        assert
      :   ( Service/toInternal
              ( Fixtures/global.Config.Default
                with Global.namespace = Some Fixtures/global.Namespace
              )
          ).namespace
        ≡ Some Fixtures/global.Namespace

let Containers/query-runner/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/containers/query-runner/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let cgDeployment = cg.query-runner.Deployment

        let cgContainers = cgDeployment.Containers

        let manipulate/options = globalOpts.ImageManipulations

        let Image =
              Image/manipulate
                manipulate/options
                cgContainers.query-runner.image

        let Resources =
              Configuration/ResourceRequirements/toK8s
                cgContainers.query-runner.resources

        let envVars =
              Util/ListToOptional
                Kubernetes/EnvVar.Type
                cgContainers.query-runner.additionalEnvVars

        let volumeMounts =
              Util/ListToOptional
                Kubernetes/VolumeMount.Type
                cgContainers.query-runner.additionalVolumeMounts

        let Config =
              { image = Image
              , resources = Resources
              , securityContext
              , envVars
              , volumeMounts
              }

        in  Config

let Test/Container/query-runner/Image =
        assert
      :   ( Containers/query-runner/toInternal
              ( Fixtures/global.Config.Default
                with query-runner.Deployment.Containers.query-runner.image
                     = Fixtures/global.Image.Base
                with Global.ImageManipulations
                     = Fixtures/global.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures/global.Image.Manipulated

let Test/Container/query-runner/Resources/none =
        assert
      :   ( Containers/query-runner/toInternal
              ( Fixtures/global.Config.Default
                with query-runner.Deployment.Containers.query-runner.resources
                     = Fixtures/global.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/Container/query-runner/Resources/some =
        assert
      :   ( Containers/query-runner/toInternal
              ( Fixtures/global.Config.Default
                with query-runner.Deployment.Containers.query-runner.resources
                     = Fixtures/global.Resources.Input
              )
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/Container/query-runner/SecurityContext/none =
        assert
      :   ( Containers/query-runner/toInternal
              (Fixtures/global.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/query-runner/SecurityContext/some =
        assert
      :   ( Containers/query-runner/toInternal
              (Fixtures/global.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Containers/jaeger/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/containers/jaeger/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let manipulate/options = globalOpts.ImageManipulations

        let opts = cg.query-runner.Deployment.Containers.jaeger

        let image = Image/manipulate manipulate/options opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        in  { image, resources, securityContext }

let Test/Containers/jaeger/Image =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with query-runner.Deployment.Containers.jaeger.image
                     = Fixtures/global.Image.Base
                with Global.ImageManipulations
                     = Fixtures/global.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures/global.Image.Manipulated

let Test/Containers/jaeger/Resources/none =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with query-runner.Deployment.Containers.jaeger.resources
                     = Fixtures/global.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/Containers/jaeger/Resources/some =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with query-runner.Deployment.Containers.jaeger.resources
                     = Fixtures/global.Resources.Input
              )
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/Containers/jaeger/SecurityContext/none =
        assert
      :   ( Containers/jaeger/toInternal
              (Fixtures/global.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Containers/jaeger/SecurityContext/some =
        assert
      :   ( Containers/jaeger/toInternal
              (Fixtures/global.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Deployment/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/deployment/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let namespace = globalOpts.namespace

        let cgDeployment = cg.query-runner.Deployment

        let Config = Containers/query-runner/toInternal cg

        let JaegerConfig = Containers/jaeger/toInternal cg

        in  { namespace
            , Containers = { query-runner = Config, jaeger = JaegerConfig }
            , sideCars = cgDeployment.additionalSideCars
            }

let Test/Deployment/Namespace/none =
        assert
      :   ( Deployment/toInternal
              (Fixtures/global.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Deployment/Namespace/Some =
        assert
      :   ( Deployment/toInternal
              ( Fixtures/global.Config.Default
                with Global.namespace = Some Fixtures/global.Namespace
              )
          ).namespace
        ≡ Some Fixtures/global.Namespace

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Deployment.query-runner = Deployment/toInternal cg
        , Service.query-runner = Service/toInternal cg
        }

in  toInternal
