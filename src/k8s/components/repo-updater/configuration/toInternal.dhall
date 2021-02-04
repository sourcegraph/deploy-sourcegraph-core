let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/Containers/repoUpdater =
      ./internal/containers/repo-updater.dhall

let Configuration/internal/Containers/jaeger =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Configuration/internal/Deployment = ./internal/deployment.dhall

let Configuration/internal/Service = ./internal/service.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let environment/toList = ./environment/toList.dhall

let Fixtures = ../../../util/test-fixtures/package.dhall

let TestConfig = Configuration/global::{=}

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let getNamespace
    : ∀(cg : Configuration/global.Type) → Optional Text
    = λ(cg : Configuration/global.Type) → cg.Global.namespace

let Containers/repoUpdater/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/repoUpdater
    = λ(cg : Configuration/global.Type) →
        let securityContext =
              if    cg.Global.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let image =
              Image/manipulate
                cg.Global.ImageManipulations
                cg.repo-updater.Deployment.Containers.repo-updater.image

        let resources =
              Configuration/ResourceRequirements/toK8s
                cg.repo-updater.Deployment.Containers.repo-updater.resources

        let envVars =
              environment/toList
                cg.repo-updater.Deployment.Containers.repo-updater.environment

        let envVars =
              Util/ListToOptional
                Kubernetes/EnvVar.Type
                (   envVars
                  # cg.repo-updater.Deployment.Containers.repo-updater.additionalEnvVars
                )

        let volumeMount =
              Util/ListToOptional
                Kubernetes/VolumeMount.Type
                cg.repo-updater.Deployment.Containers.repo-updater.additionalVolumeMounts

        in  { image
            , resources
            , securityContext
            , envVars
            , volumeMounts = volumeMount
            }

let Test/Container/repoUpdater/Environment =
        assert
      :   ( Containers/repoUpdater/toInternal
              ( Fixtures.Config.Default
                with   repo-updater
                     . Deployment
                     . Containers
                     . repo-updater
                     . environment
                     . SOURCEGRAPHDOTCOM_MODE
                     = Kubernetes/EnvVar::{
                  , name = "SOURCEGRAPHDOTCOM_MODE"
                  , value = Some "true"
                  }
              )
          ).envVars
        ≡ Some
            [ Kubernetes/EnvVar::{
              , name = "SOURCEGRAPHDOTCOM_MODE"
              , value = Some "true"
              }
            ]

let Test/Container/repoUpdater/securityContext/some =
        assert
      :   ( Containers/repoUpdater/toInternal
              (TestConfig with Global.nonRoot = True)
          ).securityContext
        ≡ Some nonRootSecurityContext

let Test/Container/repoUpdater/securityContext/none =
        assert
      :   ( Containers/repoUpdater/toInternal
              (TestConfig with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/repoUpdater/Image =
        assert
      :   ( Containers/repoUpdater/toInternal
              ( Fixtures.Config.Default
                with repo-updater.Deployment.Containers.repo-updater.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/repoUpdater/resources/none =
        assert
      :   ( Containers/repoUpdater/toInternal
              ( TestConfig
                with repo-updater.Deployment.Containers.repo-updater.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/repoUpdater/resources/some =
        assert
      :   ( Containers/repoUpdater/toInternal
              ( TestConfig
                with repo-updater.Deployment.Containers.repo-updater.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let TestContainers/repoUpdater/Image =
        assert
      :   ( Containers/repoUpdater/toInternal
              ( Fixtures.Config.Default
                with Global.ImageManipulations.registry = Some "quay.io"
              )
          ).image.registry
        ≡ Some "quay.io"

let Containers/jaeger/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/jaeger
    = λ(cg : Configuration/global.Type) →
        let securityContext =
              if    cg.Global.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let image =
              Image/manipulate
                cg.Global.ImageManipulations
                cg.repo-updater.Deployment.Containers.jaeger.image

        let resources =
              Configuration/ResourceRequirements/toK8s
                cg.repo-updater.Deployment.Containers.jaeger.resources

        let config =
              cg.repo-updater.Deployment.Containers.jaeger
              with image = image
              with resources = resources
              with securityContext = securityContext

        in  config

let Test/Container/Jaeger/Image =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures.Config.Default
                with repo-updater.Deployment.Containers.jaeger.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Jaeger/SecurityContext/some =
        assert
      :   ( Containers/jaeger/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some nonRootSecurityContext

let Test/Container/Jaeger/SecurityContext/none =
        assert
      :   ( Containers/jaeger/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Jaeger/Resources/some =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures.Config.Default
                with repo-updater.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Jaeger/Resources/none =
        assert
      :   ( Containers/jaeger/toInternal
              ( Fixtures.Config.Default
                with repo-updater.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Deployment/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/Deployment
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        let Deployment =
              { namespace
              , Containers =
                { repo-updater = Containers/repoUpdater/toInternal cg
                , jaeger = Containers/jaeger/toInternal cg
                }
              , sideCars = cg.repo-updater.Deployment.additionalSideCars
              }

        in  Deployment

let Test/Deployment/Namespace/some =
        assert
      :   ( Deployment/toInternal
              (Fixtures.Config.Default with Global.namespace = Some "foo")
          ).namespace
        ≡ Some "foo"

let Test/Deployment/Namespace/none =
        assert
      :   ( Deployment/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Service/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/Service
    = λ(cg : Configuration/global.Type) → { namespace = getNamespace cg }

let Test/Service/Namespace/Some =
        assert
      :   ( Service/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Test/Service/Namespace/None =
        assert
      :   Service/toInternal (TestConfig with Global.namespace = None Text)
        ≡ { namespace = None Text }

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Service.repo-updater = Service/toInternal cg
        , Deployment.repo-updater = Deployment/toInternal cg
        }

in  toInternal
