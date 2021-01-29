let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/Grafana/Containers =
      (../../../../simple/grafana/package.dhall).Containers

let Kubernetes/PersistentVolumeSpec =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeSpec.dhall

let Image = (../../../../util/package.dhall).Image

let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let StatefulSet/GrafanaContainer =
      { Type =
          { image : Image.Type
          , resources : Configuration/ResourceRequirements.Type
          , additionalEnvVars : List Kubernetes/EnvVar.Type
          , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
          }
      , default =
        { image = Simple/Grafana/Containers.grafana.image
        , resources =
            Configuration/ResourceRequirements::{=}
          with limits.cpu = Some "1"
          with limits.memory = Some "512Mi"
          with requests.cpu = Some "100m"
          with requests.memory = Some "512Mi"
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let StatefulSet/Containers =
      { Type = { grafana : StatefulSet/GrafanaContainer.Type }
      , default.grafana = StatefulSet/GrafanaContainer.default
      }

let StatefulSet =
      { Type =
          { Containers : StatefulSet/Containers.Type
          , dataVolumeSize : Text
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { Containers = StatefulSet/Containers.default
        , dataVolumeSize = "2Gi"
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let ConfigMap =
      { Type = { datasources : Text }
      , default.datasources
        =
          ''
          apiVersion: 1

          datasources:
            - name: Prometheus
              type: prometheus
              access: proxy
              url: http://prometheus:30090
              isDefault: true
              editable: false
            - name: Jaeger
              type: Jaeger
              access: proxy
              url: http://jaeger-query:16686/-/debug/jaeger
          ''
      }

let PersistentVolume =
      { Type = { spec : Optional Kubernetes/PersistentVolumeSpec.Type }
      , default.spec = None Kubernetes/PersistentVolumeSpec.Type
      }

let configuration =
      { Type =
          { Service : {}
          , StatefulSet : StatefulSet.Type
          , ConfigMap : ConfigMap.Type
          , PersistentVolume : PersistentVolume.Type
          }
      , default =
        { Service = {=}
        , StatefulSet = StatefulSet.default
        , ConfigMap = ConfigMap.default
        , PersistentVolume = PersistentVolume.default
        }
      }

in  configuration
