let Sourcegraph = ../../package.dhall

let c
    : Sourcegraph.Configuration.Type
    = Sourcegraph.Configuration::{=}
      with redis.Deployment.redis-cache.Containers.redis-cache.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/redis-cache"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "some-tag"
        }
      with redis.Deployment.redis-cache.Containers.redis-cache.additionalEnvVars
           =
        [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . resources
           . limits
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . resources
           . requests
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . resources
           . requests
           . memory
           = Some
          "100Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . additionalVolumeMounts
           =
        [ Sourcegraph.Kubernetes.VolumeMount::{
          , name = "fake-volume"
          , mountPath = "/your/name/should/be/in/lights"
          }
        ]
      with redis.Deployment.redis-cache.Containers.redis-exporter.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/redis_exporter"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "some-tag"
        }
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . additionalEnvVars
           =
        [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . resources
           . limits
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . resources
           . requests
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . resources
           . requests
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-exporter
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-cache
           . Containers
           . redis-cache
           . additionalVolumeMounts
           =
        [ Sourcegraph.Kubernetes.VolumeMount::{
          , name = "fake-volume"
          , mountPath = "/your/name/should/be/in/lights"
          }
        ]
      with redis.Deployment.redis-cache.additionalSideCars
           =
        [ Sourcegraph.Kubernetes.Container::{
          , args = Some [ "bash", "-c", "echo 'hello world'" ]
          , env = Some
            [ Sourcegraph.Kubernetes.EnvVar::{
              , name = "FOO"
              , value = Some "BAR"
              }
            ]
          , image = Some "index.docker.io/your/image:tag@sha256:123456"
          , name = "sidecar"
          }
        ]
      with redis.Deployment.redis-cache.additionalVolumes
           =
        [ Sourcegraph.Kubernetes.Volume::{
          , name = "your-test-volume"
          , nfs = Some Sourcegraph.Kubernetes.NFSVolumeSource::{
            , path = "TEST_PATH"
            , server = "my.testing.server.io"
            }
          }
        ]
      with redis.Deployment.redis-store.Containers.redis-store.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/redis_exporter"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "some-tag"
        }
      with redis.Deployment.redis-store.Containers.redis-store.additionalEnvVars
           =
        [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . resources
           . limits
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . resources
           . requests
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . resources
           . requests
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-store
           . additionalVolumeMounts
           =
        [ Sourcegraph.Kubernetes.VolumeMount::{
          , name = "fake-volume"
          , mountPath = "/your/name/should/be/in/lights"
          }
        ]
      with redis.Deployment.redis-store.Containers.redis-exporter.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/redis_exporter"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "some-tag"
        }
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . additionalEnvVars
           =
        [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . resources
           . limits
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . resources
           . requests
           . cpu
           = Some
          "100m"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . resources
           . requests
           . memory
           = Some
          "1Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with   redis
           . Deployment
           . redis-store
           . Containers
           . redis-exporter
           . additionalVolumeMounts
           =
        [ Sourcegraph.Kubernetes.VolumeMount::{
          , name = "fake-volume"
          , mountPath = "/your/name/should/be/in/lights"
          }
        ]
      with redis.Deployment.redis-store.additionalSideCars
           =
        [ Sourcegraph.Kubernetes.Container::{
          , args = Some [ "bash", "-c", "echo 'hello world'" ]
          , env = Some
            [ Sourcegraph.Kubernetes.EnvVar::{
              , name = "FOO"
              , value = Some "BAR"
              }
            ]
          , image = Some "index.docker.io/your/image:tag@sha256:123456"
          , name = "sidecar"
          }
        ]
      with redis.Deployment.redis-store.additionalVolumes
           =
        [ Sourcegraph.Kubernetes.Volume::{
          , name = "your-test-volume"
          , nfs = Some Sourcegraph.Kubernetes.NFSVolumeSource::{
            , path = "TEST_PATH"
            , server = "my.testing.server.io"
            }
          }
        ]

in  Sourcegraph.Generate c
