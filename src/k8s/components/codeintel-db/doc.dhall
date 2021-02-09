let Sourcegraph = ../../package.dhall

let c
    : Sourcegraph.Configuration.Type
    = Sourcegraph.Configuration::{=}
      with codeintel-db.ConfigMap.data.`codeintel-db.conf` = "fake data"
      with codeintel-db.Deployment.Containers.pgsql.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/codeintel-db"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "3.20.1"
        }
      with codeintel-db.Deployment.Containers.pgsql.resources.limits.cpu
           = Some
          "100m"
      with codeintel-db.Deployment.Containers.pgsql.resources.limits.memory
           = Some
          "1Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with codeintel-db.Deployment.Containers.pgsql.resources.requests.cpu
           = Some
          "100m"
      with codeintel-db.Deployment.Containers.pgsql.resources.requests.memory
           = Some
          "1Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with codeintel-db.Deployment.Containers.pgsql.additionalVolumeMounts
           =
        [ Sourcegraph.Kubernetes.VolumeMount::{
          , name = "FAKE_MAYBE_NOT"
          , mountPath = "/perhaps/not"
          }
        ]
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/codeintel-db"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "3.20.1"
        }
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . resources
           . limits
           . memory
           = Some
          "1Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . resources
           . requests
           . cpu
           = Some
          "100m"
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . resources
           . requests
           . memory
           = Some
          "1Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . correct-container-dir-permissions
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with codeintel-db.Deployment.Containers.pgsql-exporter.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/codeintel-db"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "3.20.1"
        }
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql-exporter
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql-exporter
           . resources
           . limits
           . memory
           = Some
          "1Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql-exporter
           . resources
           . limits
           . ephemeralStorage
           = Some
          "500Gi"
      with codeintel-db.Deployment.Containers.pgsql.resources.requests.cpu
           = Some
          "100m"
      with codeintel-db.Deployment.Containers.pgsql.resources.requests.memory
           = Some
          "1Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with   codeintel-db
           . Deployment
           . Containers
           . pgsql-exporter
           . environment
           . DATA_SOURCE_NAME
           . value
           = Some
          "my.website"
      with codeintel-db.Deployment.additionalSideCars
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
      with codeintel-db.PersistentVolumeClaim.name = "fake-name"
      with codeintel-db.PersistentVolumeClaim.selector
           = Some Sourcegraph.Kubernetes.LabelSelector::{
        , matchLabels = Some (toMap { app = "codeintel-db" })
        }
      with codeintel-db.Deployment.additionalVolumes
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
