let Kubernetes/Deployment =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/DeploymentSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentSpec.dhall

let Kubernetes/LabelSelector =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/DeploymentStrategy =
      ../../../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentStrategy.dhall

let Kubernetes/PodTemplateSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/PodSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/Volume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/PersistentVolumeClaimVolumeSource =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimVolumeSource.dhall

let Kubernetes/ConfigMapVolumeSource =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMapVolumeSource.dhall

let Configuration/Internal/Deployment =
      ../configuration/internal/deployment.dhall

let Configuration/Internal/Container/init =
      ../configuration/internal/containers/init.dhall

let Configuration/Internal/Container/pgsql =
      ../configuration/internal/containers/pgsql.dhall

let Configuration/Internal/Container/pgsql-exporter =
      ../configuration/internal/containers/exporter/exporter.dhall

let environment/toList =
      ../configuration/internal/containers/exporter/environment/toList.dhall

let util = ../../../../util/package.dhall

let k8s/util = ../../../util/package.dhall

let Simple/Postgres = ../../../../simple/postgres/package.dhall

let name = "pgsql"

let appLabel = { app = name }

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = name }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let Container/correct-data-dir-permisssions/generate
    : ∀(c : Configuration/Internal/Container/init) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/init) →
        let name = "correct-data-dir-permissions"

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let command =
              [ "sh"
              , "-c"
              , "if [ -d /data/pgdata-11 ]; then chmod 750 /data/pgdata-11; fi"
              ]

        in  Kubernetes/Container::{
            , name
            , image = Some image
            , command = Some command
            , securityContext
            , resources
            , volumeMounts = c.volumeMounts
            }

let Container/pgsql/generate
    : ∀(c : Configuration/Internal/Container/pgsql) → Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/pgsql) →
        let name = "pgsql"

        let image = util.Image/show c.image

        let securityContext = c.securityContext

        let resources = c.resources

        let simpleLiveness = Simple/Postgres.Containers.pgsql.HealthCheck

        let livenessProbe = util.HealthCheck/tok8s simpleLiveness

        let readinessProbe =
              util.HealthCheck/tok8s
                ( util.HealthCheck.Exec
                    util.ExecHealthCheck::{
                    , command = util.Command.Exec [ "/ready.sh" ]
                    }
                )

        let pgsqlPort =
              Kubernetes/ContainerPort::{
              , containerPort = Simple/Postgres.Containers.pgsql.ports.database
              , name = Some "pgsql"
              }

        in  Kubernetes/Container::{
            , image = Some image
            , name
            , env = c.envVars
            , ports = Some [ pgsqlPort ]
            , readinessProbe = Some readinessProbe
            , livenessProbe = Some livenessProbe
            , resources
            , volumeMounts = c.volumeMounts
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            }

let Container/pgsql-exporter/generate
    : ∀(c : Configuration/Internal/Container/pgsql-exporter) →
        Kubernetes/Container.Type
    = λ(c : Configuration/Internal/Container/pgsql-exporter) →
        let name = "pgsql-exporter"

        let image = util.Image/show c.image

        let environment = environment/toList c.environment

        let securityContext = c.securityContext

        let resources = c.resources

        in  Kubernetes/Container::{
            , name
            , image = Some image
            , env = Some environment
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , resources
            , securityContext
            }

let Deployment/generate
    : ∀(c : Configuration/Internal/Deployment) → Kubernetes/Deployment.Type
    = λ(c : Configuration/Internal/Deployment) →
        let name = "pgsql"

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let annotations =
              Some
                (toMap { description = "Postgres database for various data." })

        let selector =
              Kubernetes/LabelSelector::{ matchLabels = Some (toMap appLabel) }

        let backendLabel = { group = "backend" }

        let podLabels =
              Some (toMap (appLabel ∧ deploySourcegraphLabel ∧ backendLabel))

        let initContainer =
              Container/correct-data-dir-permisssions/generate
                c.Containers.correct-data-dir-permissions

        let pgsqlContainer = Container/pgsql/generate c.Containers.pgsql

        let pgsqlExporterContainer =
              Container/pgsql-exporter/generate c.Containers.pgsql-exporter

        let volumes =
              Some
                [ Kubernetes/Volume::{
                  , name = "disk"
                  , persistentVolumeClaim = Some Kubernetes/PersistentVolumeClaimVolumeSource::{
                    , claimName = c.Volumes.disk.persistentVolumeClaim.claimName
                    }
                  }
                , Kubernetes/Volume::{
                  , configMap = Some Kubernetes/ConfigMapVolumeSource::{
                    , defaultMode = Some
                        (k8s/util.Octal.toNatural k8s/util.Octal.Enum.Oo777)
                    , name = Some "pgsql-conf"
                    }
                  , name = "pgsql-conf"
                  }
                ]

        let podSecurityContext = c.podSecurityContext

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations
                , labels = Some deploymentLabels
                , name = Some name
                , namespace = c.namespace
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , revisionHistoryLimit = Some 10
                , replicas = Some 1
                , selector
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , type = Some "Recreate"
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{ labels = podLabels }
                  , spec = Some Kubernetes/PodSpec::{
                    , initContainers = Some [ initContainer ]
                    , containers =
                        [ pgsqlContainer, pgsqlExporterContainer ] # c.sideCars
                    , volumes
                    , securityContext = podSecurityContext
                    }
                  }
                }
              }

        in  deployment

in  Deployment/generate
