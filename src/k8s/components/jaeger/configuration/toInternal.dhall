let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Configuration/service/internal = ./internal/service.dhall

let Configuration/containers/jaeger/internal = ./internal/container/jaeger.dhall

let Configuration/deployment/internal = ./internal/deployment.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Util/ListToOptional = ../../../util/functions/list-to-optional.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let Service/collector/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/service/internal
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace in { namespace }

let Service/query/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/service/internal
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace in { namespace }

let Containers/jaeger/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/containers/jaeger/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let manipulate/options = globalOpts.ImageManipulations

        let opts = cg.jaeger.Deployment.Containers.jaeger

        let image = Image/manipulate manipulate/options opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let environment =
              Util/ListToOptional Kubernetes/EnvVar.Type opts.additionalEnvVars

        let volumeMounts =
              Util/ListToOptional
                Kubernetes/VolumeMount.Type
                opts.additionalVolumeMounts

        in  { image
            , resources
            , securityContext
            , envVars = environment
            , volumeMounts
            }

let Deployment/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/deployment/internal
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        let opts = cg.jaeger.Deployment

        let volumes = opts.additionalVolumes

        in  { namespace
            , Containers.jaeger = Containers/jaeger/toInternal cg
            , sideCars = opts.additionalSideCars
            , additionalVolumes = volumes
            }

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { Deployment.jaeger = Deployment/toInternal cg
        , Service.jaeger-query = Service/query/toInternal cg
        , Service.jaeger-collector = Service/collector/toInternal cg
        }

in  toInternal
