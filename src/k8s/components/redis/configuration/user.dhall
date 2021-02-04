let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/Redis/Containers =
      (../../../../simple/redis/package.dhall).Containers

let environment = ./environment/environment.dhall

let util = ../../../../util/package.dhall

let Image = util.Image

let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let ContainerConfiguration =
      { Type =
          { image : Image.Type
          , resources : Configuration/ResourceRequirements.Type
          }
      , default = {=}
      }

let redisCacheResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "1"
      with limits.memory = Some "6Gi"
      with requests.cpu = Some "1"
      with requests.memory = Some "6Gi"

let RedisCacheContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Redis/Containers.redis-cache.image
        , resources = redisCacheResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let redisExporterResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "10m"
      with limits.memory = Some "100Mi"
      with requests.cpu = Some "10m"
      with requests.memory = Some "100Mi"

let RedisExporterContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Redis/Containers.redis-exporter.image
        , resources = redisExporterResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let redisStoreResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "1"
      with limits.memory = Some "6Gi"
      with requests.cpu = Some "1"
      with requests.memory = Some "6Gi"

let RedisStoreContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Redis/Containers.redis-store.image
        , resources = redisStoreResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let RedisCacheContainers =
      { Type =
          { redis-cache : RedisCacheContainer.Type
          , redis-exporter : RedisExporterContainer.Type
          }
      , default =
        { redis-cache = RedisCacheContainer.default
        , redis-exporter = RedisExporterContainer.default
        }
      }

let RedisStoreContainers =
      { Type =
          { redis-store : RedisStoreContainer.Type
          , redis-exporter : RedisExporterContainer.Type
          }
      , default =
        { redis-store = RedisStoreContainer.default
        , redis-exporter = RedisExporterContainer.default
        }
      }

let RedisCacheDeployment =
      { Type =
          { Containers : RedisCacheContainers.Type
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { Containers = RedisCacheContainers.default
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let RedisStoreDeployment =
      { Type =
          { Containers : RedisStoreContainers.Type
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { Containers = RedisStoreContainers.default
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let RedisPersistentVolumeClaim =
      { Type = { volumeSize : Text }, default.volumeSize = "100Gi" }

let configuration =
      { Type =
          { Deployment :
              { redis-cache : RedisCacheDeployment.Type
              , redis-store : RedisStoreDeployment.Type
              }
          , PersistentVolumeClaim :
              { redis-cache : RedisPersistentVolumeClaim.Type
              , redis-store : RedisPersistentVolumeClaim.Type
              }
          }
      , default =
        { Deployment =
          { redis-cache = RedisCacheDeployment.default
          , redis-store = RedisStoreDeployment.default
          }
        , PersistentVolumeClaim =
          { redis-cache = RedisPersistentVolumeClaim.default
          , redis-store = RedisPersistentVolumeClaim.default
          }
        }
      }

in  configuration