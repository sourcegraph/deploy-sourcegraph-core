let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/deployment/redis-cache =
      ./internal/deployment/redis-cache.dhall

let Configuration/internal/deployment/redis-store =
      ./internal/deployment/redis-store.dhall

let Configuration/internal/service = ./internal/service.dhall

let Configuration/internal/Containers/redis-cache =
      ./internal/container/redis-cache.dhall

let Configuration/internal/Containers/redis-store =
      ./internal/container/redis-store.dhall

let Configuration/internal/Containers/redis-exporter =
      ./internal/container/redis-exporter.dhall

let util = ../../../../util/package.dhall

let Util/JoinOptionalList = ../../../util/functions/join-optional-list.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let environment/toList = ./environment/toList.dhall

let Simple/Redis = ../../../../simple/redis/package.dhall

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

let Container/RedisCache/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/redis-cache
    = λ(cg : Configuration/global.Type) →
        let opts = cg.redis.Deployment.redis-cache.Containers.redis-cache

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars =
              Util/JoinOptionalList
                Kubernetes/EnvVar.Type
                (Some (environment/toList opts.environment))
                (Some opts.additionalEnvVars)

        let simple/redis = Simple/Redis.Containers.redis-cache

        let redisDataVolume =
              Kubernetes/VolumeMount::{
              , mountPath = simple/redis.volumes.redis-data
              , name = "redis-data"
              }

        let volumeMounts =
              Some ([ redisDataVolume ] # opts.additionalVolumeMounts)

        in  { image, resources, securityContext, envVars, volumeMounts }

let Test/Container/RedisCache/Image =
        assert
      :   ( Container/RedisCache/toInternal
              ( Fixtures.Config.Default
                with redis.Deployment.redis-cache.Containers.redis-cache.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/RedisCache/Resources/none =
        assert
      :   ( Container/RedisCache/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-cache
                     . Containers
                     . redis-cache
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/RedisCache/Resources/some =
        assert
      :   ( Container/RedisCache/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-cache
                     . Containers
                     . redis-cache
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/RedisCache/SecurityContext/none =
        assert
      :   ( Container/RedisCache/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/RedisCache/SecurityContext/some =
        assert
      :   ( Container/RedisCache/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Container/RedisExporter/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/redis-exporter
    = λ(cg : Configuration/global.Type) →
        let opts = cg.redis.Deployment.redis-cache.Containers.redis-exporter

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        in  { image, resources, securityContext }

let Test/Container/RedisExporter/Image =
        assert
      :   ( Container/RedisExporter/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-cache
                     . Containers
                     . redis-exporter
                     . image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/RedisExporter/Resources/none =
        assert
      :   ( Container/RedisExporter/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-cache
                     . Containers
                     . redis-exporter
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/RedisExporter/Resources/some =
        assert
      :   ( Container/RedisExporter/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-cache
                     . Containers
                     . redis-exporter
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/RedisExporter/SecurityContext/none =
        assert
      :   ( Container/RedisExporter/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/RedisExporter/SecurityContext/some =
        assert
      :   ( Container/RedisExporter/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Container/RedisStore/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/redis-store
    = λ(cg : Configuration/global.Type) →
        let opts = cg.redis.Deployment.redis-store.Containers.redis-store

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars = environment/toList opts.environment

        let envVars = Some (envVars # opts.additionalEnvVars)

        let simple/redis = Simple/Redis.Containers.redis-store

        let redisDataVolume =
              Kubernetes/VolumeMount::{
              , mountPath = simple/redis.volumes.redis-data
              , name = "redis-data"
              }

        let volumeMounts =
              Some ([ redisDataVolume ] # opts.additionalVolumeMounts)

        in  { image, resources, securityContext, envVars, volumeMounts }

let Test/Container/RedisStore/Image =
        assert
      :   ( Container/RedisStore/toInternal
              ( Fixtures.Config.Default
                with redis.Deployment.redis-store.Containers.redis-store.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/RedisStore/Resources/none =
        assert
      :   ( Container/RedisStore/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-store
                     . Containers
                     . redis-store
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/RedisStore/Resources/some =
        assert
      :   ( Container/RedisStore/toInternal
              ( Fixtures.Config.Default
                with   redis
                     . Deployment
                     . redis-store
                     . Containers
                     . redis-store
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/RedisStore/SecurityContext/none =
        assert
      :   ( Container/RedisStore/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/RedisStore/SecurityContext/some =
        assert
      :   ( Container/RedisStore/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Deployment/RedisCache/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/deployment/redis-cache
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        let opts = cg.redis.Deployment.redis-cache

        in  { namespace
            , Containers =
              { redis-cache = Container/RedisCache/toInternal cg
              , redis-exporter = Container/RedisExporter/toInternal cg
              }
            , sideCars = opts.additionalSideCars
            }

let Test/Deployment/RedisCache/Namespace/none =
        assert
      :   ( Deployment/RedisCache/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Deployment/RedisCache/Namespace/Some =
        assert
      :   ( Deployment/RedisCache/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Deployment/RedisStore/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/deployment/redis-store
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        let opts = cg.redis.Deployment.redis-store

        in  { namespace
            , Containers =
              { redis-store = Container/RedisStore/toInternal cg
              , redis-exporter = Container/RedisExporter/toInternal cg
              }
            , sideCars = opts.additionalSideCars
            }

let Test/Deployment/RedisStore/Namespace/none =
        assert
      :   ( Deployment/RedisStore/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Deployment/RedisStore/Namespace/Some =
        assert
      :   ( Deployment/RedisStore/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Service/RedisCache/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/service
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/Service/RedisCache/Namespace/none =
        assert
      :   ( Service/RedisCache/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/RedisCache/Namespace/Some =
        assert
      :   ( Service/RedisCache/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Service/RedisStore/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/service
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/Service/RedisStore/Namespace/none =
        assert
      :   ( Service/RedisStore/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/RedisStore/Namespace/Some =
        assert
      :   ( Service/RedisStore/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Deployment =
          { redis-cache = Deployment/RedisCache/toInternal cg
          , redis-store = Deployment/RedisStore/toInternal cg
          }
        , Service =
          { redis-cache = Service/RedisCache/toInternal cg
          , redis-store = Service/RedisStore/toInternal cg
          }
        , PersistentVolumeClaim =
          { redis-cache =
            { volumeSize = cg.redis.PersistentVolumeClaim.redis-cache.volumeSize
            , storageClassName = cg.Global.storageClassname
            }
          , redis-store =
            { volumeSize = cg.redis.PersistentVolumeClaim.redis-store.volumeSize
            , storageClassName = cg.Global.storageClassname
            }
          }
        }

in  toInternal
