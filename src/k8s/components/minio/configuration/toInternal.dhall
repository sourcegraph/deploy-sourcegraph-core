let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Configuration/global = ../../../configuration/global.dhall

let environment/toList = ./environment/toList.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Simple/Minio = (../../../../simple/minio/package.dhall).Containers.minio

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let Service/Internal = ./internal/service.dhall

let Service/toInternal
    : ∀(cg : Configuration/global.Type) → Service/Internal
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let PersistentVolumeClaim/Internal = ./internal/persistentVolumeClaim.dhall

let PersistentVolumeClaim/toInternal
    : ∀(cg : Configuration/global.Type) → PersistentVolumeClaim/Internal
    = λ(cg : Configuration/global.Type) →
        { namespace = cg.Global.namespace
        , storageClassName = cg.Global.storageClassname
        , name = cg.minio.PersistentVolumeClaim.name
        , resources =
            Configuration/ResourceRequirements/toK8s
              cg.minio.PersistentVolumeClaim.resources
        }

let Deployment/Internal = ./internal/deployment.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let Deployment/toInternal
    : ∀(cg : Configuration/global.Type) → Deployment/Internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let cgContainers = cg.minio.Deployment.Containers

        let namespace = globalOpts.namespace

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let manipulate/options = globalOpts.ImageManipulations

        let minioImage =
              Image/manipulate manipulate/options cgContainers.minio.image

        let minioResources =
              Configuration/ResourceRequirements/toK8s
                cgContainers.minio.resources

        let envVars = environment/toList cgContainers.minio.environment

        let volumes =
              { minio-data.claimName = cg.minio.PersistentVolumeClaim.name }

        let volumeMount =
              Kubernetes/VolumeMount::{
              , mountPath = Simple/Minio.volumes.minio-data
              , name = "minio-data"
              }

        let containers =
              { minio =
                { image = minioImage
                , resources = minioResources
                , envVars = Some envVars
                , securityContext
                , volumeMounts = Some [ volumeMount ]
                }
              }

        in  { namespace, containers, volumes }

let Configuration/Internal = ./internal.dhall

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/Internal
    = λ(cg : Configuration/global.Type) →
        { Deployment = Deployment/toInternal cg
        , Service = Service/toInternal cg
        , PersistentVolumeClaim = PersistentVolumeClaim/toInternal cg
        }

let Fixtures/global = ../../../util/test-fixtures/package.dhall

let defaultUserRestouces =
      ../../../util/container-resources/resource-requirements.dhall

let fixtures =
      { userSettings =
          Configuration/global::{=}
        with Global.namespace = Some "test"
        with Global.storageClassname = Some "testClass"
        with Global.nonRoot = True
        with   minio
             . Deployment
             . Containers
             . minio
             . environment
             . MINIO_ROOT_USER
             . value
             = Some
            "FOO"
        with   minio
             . Deployment
             . Containers
             . minio
             . environment
             . MINIO_ROOT_PASSWORD
             . value
             = Some
            "BAR"
        with minio.Deployment.Containers.minio.resources.limits.cpu = Some "999"
        with minio.Deployment.Containers.minio.resources.limits.memory
             = Some
            "999"
        with minio.Deployment.Containers.minio.resources.limits.ephemeralStorage
             = Some
            "999"
        with minio.Deployment.Containers.minio.resources.requests.cpu
             = Some
            "888"
        with minio.Deployment.Containers.minio.resources.requests.memory
             = Some
            "888"
        with   minio
             . Deployment
             . Containers
             . minio
             . resources
             . requests
             . ephemeralStorage
             = Some
            "888"
        with minio.Deployment.Containers.minio.image
             =
          { name = "test"
          , registry = Some "testRegistry"
          , digest = Some "testDigest"
          , tag = "3.2.10"
          }
        with minio.PersistentVolumeClaim.name = "testPVCName"
        with minio.PersistentVolumeClaim.resources.requests.storage
             = Some
            "9999Gi"
      }

let outputs =
      { defaultSettings = toInternal Fixtures/global.Config.Default
      , userSettings = toInternal fixtures.userSettings
      , this = Fixtures/global.Config.Default.minio.PersistentVolumeClaim.name
      }

let Test/Global/Namespace =
      { Service/None =
          assert : outputs.defaultSettings.Service.namespace ≡ None Text
      , Service/Some =
          assert : outputs.userSettings.Service.namespace ≡ Some "test"
      , PersistentVolumeClaim/None =
            assert
          : outputs.defaultSettings.PersistentVolumeClaim.namespace ≡ None Text
      , PersistentVolumeClaim/Some =
            assert
          : outputs.userSettings.PersistentVolumeClaim.namespace ≡ Some "test"
      , Deployment/None =
          assert : outputs.defaultSettings.Deployment.namespace ≡ None Text
      , Deployment/Some =
          assert : outputs.userSettings.Deployment.namespace ≡ Some "test"
      }

let Test/Global/StorageClassName =
      { PersistentVolumeClaim/None =
            assert
          :   outputs.defaultSettings.PersistentVolumeClaim.storageClassName
            ≡ Some "sourcegraph"
      , PersistentVolumeClaim/Some =
            assert
          :   outputs.userSettings.PersistentVolumeClaim.storageClassName
            ≡ Some "testClass"
      }

let Test/PersistentVolumeClaim/Name =
      { PersistentVolumeClaim/Some =
            assert
          : outputs.userSettings.PersistentVolumeClaim.name ≡ "testPVCName"
      , Deployment/Some =
            assert
          :   outputs.userSettings.Deployment.volumes.minio-data.claimName
            ≡ "testPVCName"
      }

let Test/PersistentVolumeClaim/resources =
      { PersistentVolumeClaim/Some =
            assert
          :   outputs.userSettings.PersistentVolumeClaim.resources
            ≡ Configuration/ResourceRequirements/toK8s
                ( defaultUserRestouces::{=}
                  with requests.storage = Some "9999Gi"
                )
      }

let Test/Deployment/Containers/minio/environment =
      { Deployment/Some =
            assert
          :   outputs.userSettings.Deployment.containers.minio.envVars
            ≡ Some
                [ Kubernetes/EnvVar::{
                  , name = "MINIO_ROOT_USER"
                  , value = Some "FOO"
                  }
                , Kubernetes/EnvVar::{
                  , name = "MINIO_ROOT_PASSWORD"
                  , value = Some "BAR"
                  }
                ]
      }

let Test/Deployment/Containers/minio/image =
      { Deployment/Some =
            assert
          :   outputs.userSettings.Deployment.containers.minio.image
            ≡ { name = "test"
              , registry = Some "testRegistry"
              , digest = Some "testDigest"
              , tag = "3.2.10"
              }
      }

let Test/Deployment/Containers/minio/resources =
      { Deployment/Some =
            assert
          :   outputs.userSettings.Deployment.containers.minio.resources
            ≡ Configuration/ResourceRequirements/toK8s
                ( defaultUserRestouces::{=}
                  with requests.cpu = Some "888"
                  with requests.memory = Some "888"
                  with requests.ephemeralStorage = Some "888"
                  with limits.cpu = Some "999"
                  with limits.memory = Some "999"
                  with limits.ephemeralStorage = Some "999"
                )
      }

let Test/Deployment/Containers/minio/SecurityContext =
      { Deployment/Some =
            assert
          :   outputs.userSettings.Deployment.containers.minio.securityContext
            ≡ Some nonRootSecurityContext
      }

in  toInternal
