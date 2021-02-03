let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let Kubernetes/PodSecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let Service/Internal = ./internal/service.dhall

let ServiceAccount/Internal = ./internal/serviceaccount.dhall

let util = ../../../../util/package.dhall

let simple/grafana =
      (../../../../simple/grafana/package.dhall).Containers.grafana

let Fixtures = ../../../util/test-fixtures/package.dhall

let Service/toInternal
    : ∀(cg : Configuration/global.Type) → Service/Internal
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

let ServiceAccount/toInternal
    : ∀(cg : Configuration/global.Type) → ServiceAccount/Internal
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/ServiceAccount/Namespace/none =
        assert
      :   ( Service/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/ServiceAccount/Namespace/Some =
        assert
      :   ( Service/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let PersistentVolume/Internal = ./internal/persistentvolume.dhall

let PersistentVolume/toInternal
    : ∀(cg : Configuration/global.Type) → PersistentVolume/Internal
    = λ(cg : Configuration/global.Type) → cg.grafana.PersistentVolume

let ConfigMap/Internal = ./internal/configmap.dhall

let ConfigMap/toInternal
    : ∀(cg : Configuration/global.Type) → ConfigMap/Internal
    = λ(cg : Configuration/global.Type) →
        { namespace = cg.Global.namespace
        , datasources = cg.grafana.ConfigMap.datasources
        }

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

let StatefulSet/Internal = ./internal/statefulset.dhall

let StatefulSet/toInternal
    : ∀(cg : Configuration/global.Type) → StatefulSet/Internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let podSecurityContext =
              if    globalOpts.nonRoot
              then  Some Kubernetes/PodSecurityContext::{ runAsUser = Some 472 }
              else  Some Kubernetes/PodSecurityContext::{ runAsUser = Some 0 }

        let cgContainers = cg.grafana.StatefulSet.Containers

        let manipulate/options = globalOpts.ImageManipulations

        let grafanaImage =
              util.Image/manipulate
                manipulate/options
                cgContainers.grafana.image

        let grafanaResources =
              Configuration/ResourceRequirements/toK8s
                cgContainers.grafana.resources

        let environment =
              Util/ListToOptional
                Kubernetes/EnvVar.Type
                cgContainers.grafana.additionalEnvVars

        let containerVolumeMounts =
            -- TODO: add ConfigMap support for creating dashboards
            -- https://github.com/sourcegraph/sourcegraph/issues/15873
            -- , Kubernetes/VolumeMount::{
            --   , name = "dashboards"
            --   , mountPath = simple/grafana.volumes.dashboards
            --   }
                [ Kubernetes/VolumeMount::{
                  , name = "grafana-data"
                  , mountPath = simple/grafana.volumes.grafanaData
                  }
                , Kubernetes/VolumeMount::{
                  , name = "config"
                  , mountPath = simple/grafana.volumes.datasources
                  }
                ]
              # cgContainers.grafana.additionalVolumeMounts

        in  { namespace = globalOpts.namespace
            , storageClassName = globalOpts.storageClassname
            , image = grafanaImage
            , containerResources = grafanaResources
            , podSecurityContext
            , dataVolumeSize = cg.grafana.StatefulSet.dataVolumeSize
            , envVars = environment
            , volumeMounts = Some containerVolumeMounts
            , sideCars = cg.grafana.StatefulSet.additionalSideCars
            }

let Test/StatefulSet/Namespace/none =
        assert
      :   ( StatefulSet/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/StatefulSet/Namespace/Some =
        assert
      :   ( StatefulSet/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Test/StatefulSet/Images =
        assert
      :   ( StatefulSet/toInternal
              ( Fixtures.Config.Default
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
                with grafana.StatefulSet.Containers.grafana.image
                     = Fixtures.Image.Base
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Service.grafana = Service/toInternal cg
        , ServiceAccount.grafana = ServiceAccount/toInternal cg
        , StatefulSet.grafana = StatefulSet/toInternal cg
        , ConfigMap.grafana = ConfigMap/toInternal cg
        , PersistentVolume.grafana = PersistentVolume/toInternal cg
        }

in  toInternal
