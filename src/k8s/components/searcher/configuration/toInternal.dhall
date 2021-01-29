let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/service/internal = ./internal/service.dhall

let Configuration/containers/searcher/internal =
      ./internal/container/searcher.dhall

let Configuration/containers/jaeger/internal =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Configuration/deployment/internal = ./internal/deployment.dhall

let Configuration/Environment/internal = ./environment/environment.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Simple/Searcher = ../../../../simple/searcher/package.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let environment/toList = ./environment/toList.dhall

let Fixtures/global = ../../../util/test-fixtures/package.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let Service/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/service/internal
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        in  { namespace
            , debugPort = Simple/Searcher.Containers.searcher.ports.debug
            }

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

let Containers/searcher/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/containers/searcher/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let simple/searcher = Simple/Searcher.Containers.searcher

        let cgContainers = cg.searcher.Deployment.Containers

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let manipulate/options = globalOpts.ImageManipulations

        let opts = cg.searcher.Deployment.Containers.searcher

        let image = Image/manipulate manipulate/options opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let envVars = environment/toList cgContainers.searcher.environment

        let envVars = envVars # cgContainers.searcher.additionalEnvVars

        let cacheVolume =
              Kubernetes/VolumeMount::{
              , mountPath = simple/searcher.volumes.CACHE_DIR
              , name = "cache-ssd"
              }

        let volumeMounts =
              [ cacheVolume ] # cgContainers.searcher.additionalVolumeMounts

        in  { image
            , resources
            , securityContext
            , envVars = Some envVars
            , volumeMounts = Some volumeMounts
            }

let TestEnvironment
    : Configuration/Environment/internal.Type
    = { CACHE_DIR = Fixtures/global.Environment.Foo
      , POD_NAME = Fixtures/global.Environment.Bar
      , SEARCHER_CACHE_SIZE_MB = Fixtures/global.Environment.Gus
      }

let Test/Container/searcher/Environment =
        assert
      :   ( Containers/searcher/toInternal
              ( Fixtures/global.Config.Default
                with searcher.Deployment.Containers.searcher.environment
                     = TestEnvironment
              )
          ).envVars
        ≡ Some
            [ Fixtures/global.Environment.Foo
            , Fixtures/global.Environment.Bar
            , Fixtures/global.Environment.Gus
            ]

let Test/Container/searcher/Image =
        assert
      :   ( Containers/searcher/toInternal
              ( Fixtures/global.Config.Default
                with searcher.Deployment.Containers.searcher.image
                     = Fixtures/global.Image.Base
                with Global.ImageManipulations
                     = Fixtures/global.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures/global.Image.Manipulated

let Test/Container/searcher/Resources/none =
        assert
      :   ( Containers/searcher/toInternal
              ( Fixtures/global.Config.Default
                with searcher.Deployment.Containers.searcher.resources
                     = Fixtures/global.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/Container/searcher/Resources/some =
        assert
      :   ( Containers/searcher/toInternal
              ( Fixtures/global.Config.Default
                with searcher.Deployment.Containers.searcher.resources
                     = Fixtures/global.Resources.Input
              )
          ).resources
        ≡ Fixtures/global.Resources.Expected

let Test/Container/searcher/SecurityContext/none =
        assert
      :   ( Containers/searcher/toInternal
              (Fixtures/global.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/searcher/SecurityContext/some =
        assert
      :   ( Containers/searcher/toInternal
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

        let opts = cg.searcher.Deployment.Containers.jaeger

        let image = Image/manipulate manipulate/options opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        in  { image, resources, securityContext }

let Test/Containers/jaeger/Image =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with searcher.Deployment.Containers.jaeger.image
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
                with searcher.Deployment.Containers.jaeger.resources
                     = Fixtures/global.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures/global.Resources.EmptyExpected

let Test/Containers/jaeger/Resources/some =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures/global.Config.Default
                with searcher.Deployment.Containers.jaeger.resources
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

        let cgDeployment = cg.searcher.Deployment

        let SearcherConfig = Containers/searcher/toInternal cg

        let JaegerConfig = Containers/jaeger/toInternal cg

        in  { namespace
            , replicas = cgDeployment.replicas
            , volumes = cgDeployment.volumes
            , Containers = { searcher = SearcherConfig, jaeger = JaegerConfig }
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
        { Deployment.searcher = Deployment/toInternal cg
        , Service.searcher = Service/toInternal cg
        }

in  toInternal
