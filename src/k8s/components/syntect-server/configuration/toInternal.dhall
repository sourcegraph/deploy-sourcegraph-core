let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/deployment = ./internal/deployment.dhall

let Configuration/internal/service = ./internal/service.dhall

let Configuration/internal/Containers/syntect-server =
      ./internal/container/syntect-server.dhall

let util = ../../../../util/package.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

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

let Container/syntect-server/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/syntect-server
    = λ(cg : Configuration/global.Type) →
        let opts = cg.syntect-server.Deployment.Containers.syntect-server

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars =
              Util/ListToOptional Kubernetes/EnvVar.Type opts.additionalEnvVars

        let volumeMounts =
              Util/ListToOptional
                Kubernetes/VolumeMount.Type
                opts.additionalVolumeMounts

        in  { image, resources, securityContext, envVars, volumeMounts }

let Test/Container/syntect-server/Environment/none =
        assert
      :   ( Container/syntect-server/toInternal
              ( Fixtures.Config.Default
                with   syntect-server
                     . Deployment
                     . Containers
                     . syntect-server
                     . additionalEnvVars
                     = ([] : List Kubernetes/EnvVar.Type)
              )
          ).envVars
        ≡ None (List Kubernetes/EnvVar.Type)

let Test/Container/syntect-server/Environment/some =
        assert
      :   ( Container/syntect-server/toInternal
              ( Fixtures.Config.Default
                with   syntect-server
                     . Deployment
                     . Containers
                     . syntect-server
                     . additionalEnvVars
                     =
                  [ Fixtures.Environment.Gus ]
              )
          ).envVars
        ≡ Some [ Fixtures.Environment.Gus ]

let Test/Container/syntect-server/Image =
        assert
      :   ( Container/syntect-server/toInternal
              ( Fixtures.Config.Default
                with syntect-server.Deployment.Containers.syntect-server.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/syntect-server/Resources/none =
        assert
      :   ( Container/syntect-server/toInternal
              ( Fixtures.Config.Default
                with   syntect-server
                     . Deployment
                     . Containers
                     . syntect-server
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/syntect-server/Resources/some =
        assert
      :   ( Container/syntect-server/toInternal
              ( Fixtures.Config.Default
                with   syntect-server
                     . Deployment
                     . Containers
                     . syntect-server
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/syntect-server/SecurityContext/none =
        assert
      :   ( Container/syntect-server/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/syntect-server/SecurityContext/some =
        assert
      :   ( Container/syntect-server/toInternal
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

        let opts = cg.syntect-server.Deployment

        let volumes = opts.additionalVolumes

        in  { namespace
            , volumes
            , Containers.syntect-server = Container/syntect-server/toInternal cg
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

let Test/Deployment/Volumes =
        assert
      :   ( Deployment/toInternal
              ( Fixtures.Config.Default
                with syntect-server.Deployment.additionalVolumes
                     =
                  [ Fixtures.Volumes.NFS, Fixtures.Volumes.Foo ]
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
        { Deployment.syntect-server = Deployment/toInternal cg
        , Service.syntect-server = Service/toInternal cg
        }

in  toInternal
