let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/Probe =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/PodSecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Configuration/global = ../../../configuration/global.dhall

let environment/toList = ./environment/toList.dhall

let Configuration/internal = ./internal.dhall

let util = ../../../../util/package.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let simple/gitserver =
      (../../../../simple/gitserver/package.dhall).Containers.gitserver

let Fixtures = ../../../util/test-fixtures/package.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let Service/Internal = ./internal/service.dhall

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

let PersistentVolumes/Internal = ./internal/persistentvolumes.dhall

let PersistentVolumes/toInternal
    : ∀(cg : Configuration/global.Type) → PersistentVolumes/Internal
    = λ(cg : Configuration/global.Type) →
        { namespace = cg.Global.namespace
        , replicas = cg.gitserver.StatefulSet.replicas
        , pvg = cg.gitserver.PersistentVolumeGenerator
        }

let Test/PersistentVolumes/replicas =
        assert
      :   ( PersistentVolumes/toInternal
              ( Fixtures.Config.Default
                with gitserver.StatefulSet.replicas = Fixtures.Replicas
              )
          ).replicas
        ≡ Fixtures.Replicas

let getSecurityContext
    : ∀(cg : Configuration/global.Type) →
        Optional Kubernetes/SecurityContext.Type
    = λ(cg : Configuration/global.Type) →
        if    cg.Global.nonRoot
        then  Some nonRootSecurityContext
        else  None Kubernetes/SecurityContext.Type

let Configuration/internal/jaeger =
      ../../shared/jaeger/configuration/internal/jaeger/jaeger.dhall

let Container/Jaeger/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/jaeger
    = λ(cg : Configuration/global.Type) →
        let opts = cg.symbols.Deployment.Containers.jaeger

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        in  { image, resources, securityContext }

let Test/Container/Jaeger/Image =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.jaeger.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Jaeger/Resources/none =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Jaeger/Resources/some =
        assert
      :   ( Container/Jaeger/toInternal
              ( Fixtures.Config.Default
                with symbols.Deployment.Containers.jaeger.resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Jaeger/SecurityContext/none =
        assert
      :   ( Container/Jaeger/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Jaeger/SecurityContext/some =
        assert
      :   ( Container/Jaeger/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let StatefulSet/Internal = ./internal/statefulset.dhall

let intOrString =
      ../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let StatefulSet/toInternal
    : ∀(cg : Configuration/global.Type) → StatefulSet/Internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let podSecurityContext =
              if    globalOpts.nonRoot
              then  Some Kubernetes/PodSecurityContext::{ runAsUser = Some 100 }
              else  Some Kubernetes/PodSecurityContext::{ runAsUser = Some 0 }

        let cgContainers = cg.gitserver.StatefulSet.Containers

        let manipulate/options = globalOpts.ImageManipulations

        let gitserverImage =
              util.Image/manipulate
                manipulate/options
                cgContainers.gitserver.image

        let gitserverResources =
              Configuration/ResourceRequirements/toK8s
                cgContainers.gitserver.resources

        let gitServerHealthCheck =
              Kubernetes/Probe::{
              , initialDelaySeconds = Some 5
              , tcpSocket = Some
                { port = intOrString.Int simple/gitserver.ports.rpc
                , host = None Text
                }
              , timeoutSeconds = Some 5
              }

        let environment = environment/toList cgContainers.gitserver.environment

        let environment = environment # cgContainers.gitserver.additionalEnvVars

        let reposVolumeMount =
              Kubernetes/VolumeMount::{
              , mountPath = simple/gitserver.volumes.repos
              , name = "repos"
              }

        let volumeMounts =
                [ reposVolumeMount ]
              # cgContainers.gitserver.additionalVolumeMounts

        let gitserverContainer =
              { image = gitserverImage
              , rpc/port = simple/gitserver.ports.rpc
              , reposVolumeSize = cg.gitserver.StatefulSet.reposVolumeSize
              , containerResources = gitserverResources
              , healthcheck = gitServerHealthCheck
              , securityContext
              , envVars = Some environment
              , volumeMounts = Some volumeMounts
              }

        in  { namespace = globalOpts.namespace
            , storageClassName = globalOpts.storageClassname
            , replicas = cg.gitserver.StatefulSet.replicas
            , Containers =
              { gitserver = gitserverContainer
              , jaeger = Container/Jaeger/toInternal cg
              }
            , podSecurityContext
            , sideCars = cg.gitserver.StatefulSet.additionalSideCars
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

let Test/StatefulSet/Replicas =
        assert
      :   ( StatefulSet/toInternal
              ( Fixtures.Config.Default
                with gitserver.StatefulSet.replicas = Fixtures.Replicas
              )
          ).replicas
        ≡ Fixtures.Replicas

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { service = Service/toInternal cg
        , statefulset = StatefulSet/toInternal cg
        , persistentvolumes = PersistentVolumes/toInternal cg
        }

in  toInternal
