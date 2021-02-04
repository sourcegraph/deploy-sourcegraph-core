let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/deployment = ./internal/deployment.dhall

let Configuration/internal/service = ./internal/service.dhall

let Configuration/internal/Volumes = ./volumes/volumes.dhall

let Configuration/internal/Environment = ./environment/environment.dhall

let Configuration/internal/jaeger =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Configuration/internal/Containers/symbols =
      ./internal/container/symbols.dhall

let util = ../../../../util/package.dhall

let environment/toList = ./environment/toList.dhall

let volumes/toList = ./volumes/toList.dhall

let Simple/Symbols = ../../../../simple/symbols/package.dhall

let Image/manipulate = util.Image/manipulate

let Fixtures = ../../../util/test-fixtures/package.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let getSecurityContext
    : ∀(cg : Configuration/global.Type) →
        Optional Kubernetes/SecurityContext.Type
    = λ(cg : Configuration/global.Type) →
        if    cg.Global.nonRoot
        then  Some nonRootSecurityContext
        else  None Kubernetes/SecurityContext.Type

let Container/Symbols/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/symbols
    = λ(cg : Configuration/global.Type) →
        let opts = cg.symbols.Deployment.Containers.symbols

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars = environment/toList opts.environment

        let envVars = Some (envVars # opts.additionalEnvVars)

        let simple/symbols = Simple/Symbols.Containers.symbols

        let cacheVolume =
              Kubernetes/VolumeMount::{
              , mountPath = simple/symbols.volumes.CACHE_DIR
              , name = "cache-ssd"
              }

        let volumeMounts = Some ([ cacheVolume ] # opts.additionalVolumeMounts)

        in  { image, resources, securityContext, envVars, volumeMounts }

let TestEnvironment
    : Configuration/internal/Environment.Type
    = { -- Note: I did it this way to make this test robust against adding/changing environment variables in the future.
        CACHE_DIR = Fixtures.Environment.Secret
      , POD_NAME = Fixtures.Environment.Secret
      , SYMBOLS_CACHE_SIZE_MB = Fixtures.Environment.Secret
      }

let Test/Container/Symbols/Environment =
        assert
      :   ( Container/Symbols/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.symbols.environment
                     = TestEnvironment
              )
          ).envVars
        ≡ Some (environment/toList TestEnvironment)

let Test/Container/Symbols/Image =
        assert
      :   ( Container/Symbols/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.symbols.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Symbols/Resources/none =
        assert
      :   ( Container/Symbols/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.symbols.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Symbols/Resources/some =
        assert
      :   ( Container/Symbols/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.symbols.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Symbols/SecurityContext/none =
        assert
      :   ( Container/Symbols/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Symbols/SecurityContext/some =
        assert
      :   ( Container/Symbols/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Container/Jaeger/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/jaeger
    = λ(cg : Configuration/global.Type) →
        let opts = cg.symbols.Deployment.Containers.jaeger

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        in  { image, resources, securityContext }

let Test/Container/Jaeger/Image =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.jaeger.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Jaeger/Resources/none =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Jaeger/Resources/some =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Jaeger/SecurityContext/none =
        assert
      :   ( Container/Jaeger/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Jaeger/SecurityContext/some =
        assert
      :   ( Container/Jaeger/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Deployment/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/deployment
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        let opts = cg.symbols.Deployment

        let replicas = opts.replicas

        let volumes = volumes/toList opts.volumes # opts.additionalVolumes

        in  { namespace
            , replicas
            , volumes
            , Containers =
              { symbols = Container/Symbols/toInternal cg
              , jaeger = Container/Jaeger/toInternal cg
              }
            , sideCars = opts.additionalSideCars
            }

let Test/Deployment/Namespace/none =
        assert
      :   ( Deployment/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Deployment/Namespace/Some =
        assert
      :   ( Deployment/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Test/Deployment/Replicas =
        assert
      :   ( Deployment/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.replicas = Fixtures.Replicas
              )
          ).replicas
        ≡ Fixtures.Replicas

let TestVolume
    : Configuration/internal/Volumes.Type
    = { -- Note: I did it this way to make this test robust against adding/chaning volumes in the future.
        cache-ssd = Fixtures.Volumes.NFS
      }

let Test/Deployment/Volumes =
        assert
      :   ( Deployment/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.volumes = TestVolume
                with symbols.Deployment.additionalVolumes
                     =
                  [ Fixtures.Volumes.Foo ]
              )
          ).volumes
        ≡ [ Fixtures.Volumes.NFS, Fixtures.Volumes.Foo ]

let Service/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/service
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/Service/Namespace/none =
        assert
      :   ( Service/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/Namespace/Some =
        assert
      :   ( Service/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Deployment.symbols = Deployment/toInternal cg
        , Service.symbols = Service/toInternal cg
        }

in  toInternal
