let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/deployment = ./internal/deployment.dhall

let Configuration/internal/service = ./internal/service.dhall

let Configuration/internal/Containers/preciseCodeIntelWorker =
      ./internal/containers/precise-code-intel-worker.dhall

let Configuration/internal/Environment = ./environment/environment.dhall

let util = ../../../../util/package.dhall

let Image/manipulate = util.Image/manipulate

let environment/toList = ./environment/toList.dhall

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

let Container/PreciseCodeIntel/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/preciseCodeIntelWorker
    = λ(cg : Configuration/global.Type) →
        let opts =
              cg.precise-code-intel.Deployment.Containers.precise-code-intel

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars = environment/toList opts.environment

        let envVars = Some (envVars # opts.additionalEnvVars)

        in  { image, resources, securityContext, envVars }

let TestEnvironment
    : Configuration/internal/Environment.Type
    = { POD_NAME = Fixtures.Environment.Secret
      , NUM_WORKERS = Kubernetes/EnvVar::{
        , name = "NUM_WORKERS"
        , value = Some "5"
        }
      }

let Test/Container/PreciseCodeIntel/Environment =
        assert
      :   ( Container/PreciseCodeIntel/toInternal
              ( Fixtures.Config.Default
                with   precise-code-intel
                     . Deployment
                     . Containers
                     . precise-code-intel
                     . environment
                     = TestEnvironment
              )
          ).envVars
        ≡ Some (environment/toList TestEnvironment)

let Test/Container/PreciseCodeIntel/Image =
        assert
      :   ( Container/PreciseCodeIntel/toInternal
              ( Fixtures.Config.Default
                with   precise-code-intel
                     . Deployment
                     . Containers
                     . precise-code-intel
                     . image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/PreciseCodeIntel/Resources/none =
        assert
      :   ( Container/PreciseCodeIntel/toInternal
              ( Fixtures.Config.Default
                with   precise-code-intel
                     . Deployment
                     . Containers
                     . precise-code-intel
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/PreciseCodeIntel/Resources/some =
        assert
      :   ( Container/PreciseCodeIntel/toInternal
              ( Fixtures.Config.Default
                with   precise-code-intel
                     . Deployment
                     . Containers
                     . precise-code-intel
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/PreciseCodeIntel/SecurityContext/none =
        assert
      :   ( Container/PreciseCodeIntel/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/PreciseCodeIntel/SecurityContext/some =
        assert
      :   ( Container/PreciseCodeIntel/toInternal
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

        let opts = cg.precise-code-intel.Deployment

        in  { namespace
            , Containers.precise-code-intel-worker
              = Container/PreciseCodeIntel/toInternal cg
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
        { Deployment.precise-code-intel-worker = Deployment/toInternal cg
        , Service.precise-code-intel-worker = Service/toInternal cg
        }

in  toInternal
