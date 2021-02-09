let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/Postgres/Containers =
      (../../../../simple/postgres/package.dhall).Containers

let exporterEnv = ./internal/containers/exporter/environment/environment.dhall

let util = ../../../../util/package.dhall

let Kubernetes/LabelSelector =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Image = util.Image

let Simple/images = ../../../../simple/images.dhall

let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let ContainerConfiguration =
      { Type =
          { image : Image.Type
          , resources : Configuration/ResourceRequirements.Type
          }
      , default = {=}
      }

let initContainerResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}

let alpineImge =
      Simple/images.sourcegraph/alpine
      with tag = "3.12"
      with digest = Some
          "133a0a767b836cf86a011101995641cf1b5cbefb3dd212d78d7be145adde636d"

let InitContainer =
      { Type = ContainerConfiguration.Type
      , default = { image = alpineImge, resources = initContainerResources }
      }

let pgsqlResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "4"
      with limits.memory = Some "2Gi"
      with requests.cpu = Some "4"
      with requests.memory = Some "2Gi"

let PgsqlContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { image = Simple/Postgres/Containers.pgsql.image
        , resources = pgsqlResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let postgresExporterResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "10m"
      with limits.memory = Some "50Mi"
      with requests.cpu = Some "10m"
      with requests.memory = Some "50Mi"

let PostgresExporter =
      { Type = ContainerConfiguration.Type ⩓ { environment : exporterEnv.Type }
      , default =
        { environment = exporterEnv.default
        , image = Simple/images.sourcegraph/postgres_exporter
        , resources = postgresExporterResources
        }
      }

let Containers =
      { Type =
          { correct-container-dir-permissions : InitContainer.Type
          , pgsql : PgsqlContainer.Type
          , pgsql-exporter : PostgresExporter.Type
          }
      , default =
        { correct-container-dir-permissions = InitContainer.default
        , pgsql = PgsqlContainer.default
        , pgsql-exporter = PostgresExporter.default
        }
      }

let Deployment =
      { Type =
          { Containers : Containers.Type
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { Containers = Containers.default
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let PersistentVolumeClaim =
      { Type =
          { name : Text, selector : Optional Kubernetes/LabelSelector.Type }
      , default =
        { name = "pgsql", selector = None Kubernetes/LabelSelector.Type }
      }

let ConfigMap =
      { Type = { data : { `postgresql.conf` : Text } }
      , default.data.`postgresql.conf` = ./internal/postgresql.conf as Text
      }

let configuration =
      { Type =
          { Deployment : Deployment.Type
          , PersistentVolumeClaim : PersistentVolumeClaim.Type
          , ConfigMap : ConfigMap.Type
          }
      , default.Deployment = Deployment.default
      , default.PersistentVolumeClaim = PersistentVolumeClaim.default
      , default.ConfigMap = ConfigMap.default
      }

in  configuration
