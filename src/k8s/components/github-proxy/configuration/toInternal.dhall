let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/service/internal = ./internal/service.dhall

let Configuration/containers/github-proxy/internal =
      ./internal/container/github-proxy.dhall

let Configuration/containers/jaeger/internal =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Configuration/deployment/internal = ./internal/deployment.dhall

let Configuration/Environment/internal = ./environment/environment.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let Fixtures/global = ../../../util/test-fixtures/package.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

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

let environment/toList = ./environment/toList.dhall

let Containers/github-proxy/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/containers/github-proxy/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let manipulate/options = globalOpts.ImageManipulations

        let opts = cg.github-proxy.Deployment.Containers.github-proxy

        let image = Image/manipulate manipulate/options opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let environment = environment/toList opts.environment

        let environment =
              Util/ListToOptional
                Kubernetes/EnvVar.Type
                (environment # opts.additionalEnvVars)

        let volumeMounts =
              Util/ListToOptional
                Kubernetes/VolumeMount.Type
                opts.additionalVolumeMounts

        in  { image
            , resources
            , securityContext
            , envVars = environment
            , volumeMounts
            }

let TestEnvironment
    : Configuration/Environment/internal.Type
    = { -- Note: I did it this way to make this test robust against adding/changing environment variables in the future.
        LOG_REQUESTS = Fixtures/global.Environment.Secret
      }

let Test/Container/github-proxy/Environment =
        assert
      :   ( Containers/github-proxy/toInternal
              ( Fixtures/global.Config.Default
                with github-proxy.Deployment.Containers.github-proxy.environment
                     = TestEnvironment
              )
          ).envVars
        ≡ Some [ Fixtures/global.Environment.Secret ]

let Test/Container/github-proxy/Image =
        assert
      :   ( Containers/github-proxy/toInternal
              ( Fixtures/global.Config.Default
                with github-proxy.Deployment.Containers.github-proxy.image
                     = Fixtures/global.Image.Base
                with Global.ImageManipulations
                     = Fixtures/global.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures/global.Image.Manipulated

let Test/Container/github-proxy/Resources/none =
        assert
      :   ( Containers/github-proxy/toInternal
              ( Fixtures/global.Config.Default
                with github-proxy.Deployment.Containers.github-proxy.resources
                     = Fixtures/global.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/Container/github-proxy/Resources/some =
        assert
      :   ( Containers/github-proxy/toInternal
              ( Fixtures/global.Config.Default
                with github-proxy.Deployment.Containers.github-proxy.resources
                     = Fixtures/global.Resources.Input
              )
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/Container/github-proxy/SecurityContext/none =
        assert
      :   ( Containers/github-proxy/toInternal
              (Fixtures/global.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/github-proxy/SecurityContext/some =
        assert
      :   ( Containers/github-proxy/toInternal
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

        let opts = cg.github-proxy.Deployment.Containers.jaeger

        let image = Image/manipulate manipulate/options opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        in  { image, resources, securityContext }

let Test/Containers/jaeger/Image =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with github-proxy.Deployment.Containers.jaeger.image
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
                with github-proxy.Deployment.Containers.jaeger.resources
                     = Fixtures/global.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/Containers/jaeger/Resources/some =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with github-proxy.Deployment.Containers.jaeger.resources
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
        let namespace = cg.Global.namespace

        in  { namespace
            , Containers =
              { github-proxy = Containers/github-proxy/toInternal cg
              , jaeger = Containers/jaeger/toInternal cg
              }
            , sideCars = cg.github-proxy.Deployment.additionalSideCars
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
        { Deployment.github-proxy = Deployment/toInternal cg
        , Service.github-proxy = Service/toInternal cg
        }

in  toInternal
