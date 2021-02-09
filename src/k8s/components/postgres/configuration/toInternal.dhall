let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/ConfigMap = ./internal/configmap.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

let Configuration/Internal/Containers/init = ./internal/containers/init.dhall

let Configuration/Internal/Containers/pgsql = ./internal/containers/pgsql.dhall

let Configuration/Internal/Containers/pgsql-exporter =
      ./internal/containers/exporter/exporter.dhall

let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/PodSecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let Configuration/Internal/PersistentVolumeClaim =
      ./internal/persistentVolumeClaim.dhall

let Configuration/Internal = ./internal.dhall

let Configuration/Global = ../../../configuration/global.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Simple/Postgres = ../../../../simple/postgres/package.dhall

let Fixtures = ../../../util/test-fixtures/package.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 999
      , runAsGroup = Some 999
      , allowPrivilegeEscalation = Some False
      }

let getNamespace
    : ∀(cg : Configuration/Global.Type) → Optional Text
    = λ(cg : Configuration/Global.Type) → cg.Global.namespace

let PersistentVolumeClaim/toInternal
    : ∀(cg : Configuration/Global.Type) →
        Configuration/Internal/PersistentVolumeClaim
    = λ(cg : Configuration/Global.Type) →
        let namespace = getNamespace cg

        let c = cg.pgsql.PersistentVolumeClaim

        let name = c.name

        let selector = c.selector

        in  { namespace, name, selector }

let Test/PersistentVolumeClaim =
        assert
      :   PersistentVolumeClaim/toInternal
            ( Fixtures.Config.Default
              with pgsql.PersistentVolumeClaim.selector
                   = Some
                  Fixtures.PersistentVolumeClaim.selector
              with Global.namespace = Some Fixtures.Namespace
            )
        ≡ { name = "pgsql"
          , namespace = Some Fixtures.Namespace
          , selector = Some Fixtures.PersistentVolumeClaim.selector
          }

let Service/toInternal
    : ∀(cg : Configuration/Global.Type) → Configuration/Internal/Service
    = λ(cg : Configuration/Global.Type) → { namespace = getNamespace cg }

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

let ConfigMap/toInternal
    : ∀(cg : Configuration/Global.Type) → Configuration/Internal/ConfigMap
    = λ(cg : Configuration/Global.Type) →
        let namespace = getNamespace cg

        let c = cg.pgsql.ConfigMap

        in  { namespace, data.`postgresql.conf` = c.data.`postgresql.conf` }

let Test/ConfigMap/Namespace/none =
        assert
      :   ( Service/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/ConfigMap/Namespace/Some =
        assert
      :   ( Service/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let dataDiskVolumeMount =
      Kubernetes/VolumeMount::{
      , mountPath = Simple/Postgres.Containers.pgsql.volumes.data
      , name = "disk"
      }

let Containers/init/toInternal
    : ∀(cg : Configuration/Global.Type) → Configuration/Internal/Containers/init
    = λ(cg : Configuration/Global.Type) →
        let c = cg.pgsql.Deployment.Containers.correct-container-dir-permissions

        let image = Image/manipulate cg.Global.ImageManipulations c.image

        let resources = Configuration/ResourceRequirements/toK8s c.resources

        let securityContext =
              if    cg.Global.nonRoot
              then  Some nonRootSecurityContext
              else  Some Kubernetes/SecurityContext::{ runAsUser = Some 0 }

        let volumeMounts = Some [ dataDiskVolumeMount ]

        in  { image, resources, securityContext, volumeMounts }

let Test/Container/init/SecurityContext/none =
        assert
      :   ( Containers/init/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ Some Kubernetes/SecurityContext::{ runAsUser = Some 0 }

let Test/Container/init/SecurityContext/some =
        assert
      :   ( Containers/init/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some nonRootSecurityContext

let Test/Container/init/Image =
        assert
      :   ( Containers/init/toInternal
              ( Fixtures.Config.Default
                with   pgsql
                     . Deployment
                     . Containers
                     . correct-container-dir-permissions
                     . image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Containers/pgsql/toInternal
    : ∀(cg : Configuration/Global.Type) →
        Configuration/Internal/Containers/pgsql
    = λ(cg : Configuration/Global.Type) →
        let c = cg.pgsql.Deployment.Containers.pgsql

        let manipulate/options = cg.Global.ImageManipulations

        let pgsqlImage = Image/manipulate manipulate/options c.image

        let resources = Configuration/ResourceRequirements/toK8s c.resources

        let environment =
              Util/ListToOptional Kubernetes/EnvVar.Type c.additionalEnvVars

        let volumeMounts =
                [ dataDiskVolumeMount
                , Kubernetes/VolumeMount::{
                  , mountPath = "/conf"
                  , name = "pgsql-conf"
                  }
                ]
              # c.additionalVolumeMounts

        let securityContext =
              if    cg.Global.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        in  { image = pgsqlImage
            , resources
            , securityContext
            , envVars = environment
            , volumeMounts = Some volumeMounts
            }

let Test/Container/pgsql/SecurityContext/none =
        assert
      :   ( Containers/pgsql/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/pgsql/SecurityContext/some =
        assert
      :   ( Containers/pgsql/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some nonRootSecurityContext

let Test/Container/pgsql/Resources/none =
        assert
      :   ( Containers/pgsql/toInternal
              ( Fixtures.Config.Default
                with pgsql.Deployment.Containers.pgsql.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/pgsql/Resources/some =
        assert
      :   ( Containers/pgsql/toInternal
              ( Fixtures.Config.Default
                with pgsql.Deployment.Containers.pgsql.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/pgsql/Image =
        assert
      :   ( Containers/pgsql/toInternal
              ( Fixtures.Config.Default
                with pgsql.Deployment.Containers.pgsql.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Containers/pgsql-exporter/toInternal
    : ∀(cg : Configuration/Global.Type) →
        Configuration/Internal/Containers/pgsql-exporter
    = λ(cg : Configuration/Global.Type) →
        let c = cg.pgsql.Deployment.Containers.pgsql-exporter

        let image = Image/manipulate cg.Global.ImageManipulations c.image

        let resources = Configuration/ResourceRequirements/toK8s c.resources

        let securityContext =
              if    cg.Global.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let environment = c.environment

        in  { image, resources, securityContext, environment }

let Test/Container/pgsql-exporter/SecurityContext/some =
        assert
      :   ( Containers/pgsql-exporter/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some nonRootSecurityContext

let Test/Container/pgsql-exporter/SecurityContext/none =
        assert
      :   ( Containers/pgsql-exporter/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/pgsql-exporter/resources/none =
        assert
      :   ( Containers/pgsql-exporter/toInternal
              ( Fixtures.Config.Default
                with pgsql.Deployment.Containers.pgsql-exporter.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/pgsql-exporter/resources/some =
        assert
      :   ( Containers/pgsql-exporter/toInternal
              ( Fixtures.Config.Default
                with pgsql.Deployment.Containers.pgsql-exporter.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Deployment/toInternal
    : ∀(cg : Configuration/Global.Type) → Configuration/Internal/Deployment
    = λ(cg : Configuration/Global.Type) →
        let namespace = getNamespace cg

        let containers =
              { correct-data-dir-permissions = Containers/init/toInternal cg
              , pgsql = Containers/pgsql/toInternal cg
              , pgsql-exporter = Containers/pgsql-exporter/toInternal cg
              }

        let Volumes =
              { disk.persistentVolumeClaim.claimName
                = cg.pgsql.PersistentVolumeClaim.name
              }

        let podSecurityContext =
              Some
                Kubernetes/PodSecurityContext::{
                , -- Having this seems like an error on our part
                  runAsUser = Some
                    0
                }

        in  { namespace
            , Containers = containers
            , Volumes
            , podSecurityContext
            , sideCars = cg.pgsql.Deployment.additionalSideCars
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

let toInternal
    : ∀(cg : Configuration/Global.Type) → Configuration/Internal
    = λ(cg : Configuration/Global.Type) →
        { Service = Service/toInternal cg
        , ConfigMap = ConfigMap/toInternal cg
        , PersistentVolumeClaim = PersistentVolumeClaim/toInternal cg
        , Deployment = Deployment/toInternal cg
        }

in  toInternal
