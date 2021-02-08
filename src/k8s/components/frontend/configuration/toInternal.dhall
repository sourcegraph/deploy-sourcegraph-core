let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/deployment = ./internal/deployment.dhall

let Configuration/internal/service/sourcegraph-frontend =
      ./internal/service/sourcegraph-frontend.dhall

let Configuration/internal/service/sourcegraph-frontend-internal =
      ./internal/service/sourcegraph-frontend-internal.dhall

let Configuration/internal/Volumes = ./volumes/volumes.dhall

let Configuration/internal/jaeger =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Configuration/internal/Containers/frontend =
      ./internal/container/frontend.dhall

let util = ../../../../util/package.dhall

let environment/toList = ./environment/toList.dhall

let volumes/toList = ./volumes/toList.dhall

let Simple/Frontend = ../../../../simple/frontend/package.dhall

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

let Container/Frontend/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/frontend
    = λ(cg : Configuration/global.Type) →
        let opts = cg.frontend.Deployment.Containers.frontend

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars = environment/toList opts.environment

        let envVars = Some (envVars # opts.additionalEnvVars)

        let simple/frontend = Simple/Frontend.Containers.frontend

        let cacheVolume =
              Kubernetes/VolumeMount::{
              , mountPath = simple/frontend.volumes.CACHE_DIR
              , name = "cache-ssd"
              }

        let volumeMounts = Some ([ cacheVolume ] # opts.additionalVolumeMounts)

        in  { image, resources, securityContext, envVars, volumeMounts }

let Test/Container/Frontend/Image =
        assert
      :   ( Container/Frontend/toInternal
              ( Fixtures.Config.Default
                with frontend.Deployment.Containers.frontend.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Frontend/Resources/none =
        assert
      :   ( Container/Frontend/toInternal
              ( Fixtures.Config.Default
                with frontend.Deployment.Containers.frontend.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Frontend/Resources/some =
        assert
      :   ( Container/Frontend/toInternal
              ( Fixtures.Config.Default
                with frontend.Deployment.Containers.frontend.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Frontend/SecurityContext/none =
        assert
      :   ( Container/Frontend/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Frontend/SecurityContext/some =
        assert
      :   ( Container/Frontend/toInternal
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
        let opts = cg.frontend.Deployment.Containers.jaeger

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        in  { image, resources, securityContext }

let Test/Container/Jaeger/Image =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with frontend.Deployment.Containers.jaeger.image
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
                with frontend.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Jaeger/Resources/some =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with frontend.Deployment.Containers.jaeger.resources
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

        let opts = cg.frontend.Deployment

        let replicas = opts.replicas

        let volumes = volumes/toList opts.volumes # opts.additionalVolumes

        in  { namespace
            , replicas
            , volumes
            , Containers =
              { frontend = Container/Frontend/toInternal cg
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
                with frontend.Deployment.replicas = Fixtures.Replicas
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
                with frontend.Deployment.volumes = TestVolume
                with frontend.Deployment.additionalVolumes
                     =
                  [ Fixtures.Volumes.Foo ]
              )
          ).volumes
        ≡ [ Fixtures.Volumes.NFS, Fixtures.Volumes.Foo ]

let Service/sourcegraph-frontend/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/service/sourcegraph-frontend
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Service/sourcegraph-frontend-internal/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/service/sourcegraph-frontend-internal
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/Service/sourcegraph-frontend/Namespace/none =
        assert
      :   ( Service/sourcegraph-frontend/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/sourcegraph-frontend/Namespace/Some =
        assert
      :   ( Service/sourcegraph-frontend/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Test/Service/sourcegraph-frontend-internal/Namespace/none =
        assert
      :   ( Service/sourcegraph-frontend-internal/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/sourcegraph-frontend-internal/Namespace/Some =
        assert
      :   ( Service/sourcegraph-frontend-internal/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Deployment.sourcegraph-frontend = Deployment/toInternal cg
        , Service =
          { sourcegraph-frontend = Service/sourcegraph-frontend/toInternal cg
          , sourcegraph-frontend-internal =
              Service/sourcegraph-frontend-internal/toInternal cg
          }
        }

in  toInternal
