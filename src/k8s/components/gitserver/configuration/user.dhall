let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/Gitserver/Containers =
      (../../../../simple/gitserver/package.dhall).Containers

let environment = ./environment/environment.dhall

let util = ../../../../util/package.dhall

let Image = util.Image

let Configuration/jaeger = ../../shared/jaeger/defaults.dhall

let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let ContainerConfiguration =
      { Type =
          { image : Image.Type
          , resources : Configuration/ResourceRequirements.Type
          }
      , default = {=}
      }

let gitserverResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "4"
      with limits.memory = Some "8G"
      with requests.cpu = Some "4"
      with requests.memory = Some "8G"

let GitserverContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Gitserver/Containers.gitserver.image
        , resources = gitserverResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let JaegerContainer =
      ContainerConfiguration
      with default.image = Configuration/jaeger.Image
      with default.resources = Configuration/jaeger.Resources

let Containers =
      { Type =
          { gitserver : GitserverContainer.Type, jaeger : JaegerContainer.Type }
      , default =
        { gitserver = GitserverContainer.default
        , jaeger = JaegerContainer.default
        }
      }

let StatefulSet =
      { Type =
          { Containers : Containers.Type
          , replicas : Natural
          , reposVolumeSize : Text
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { Containers = Containers.default
        , replicas = 1
        , reposVolumeSize = "200Gi"
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let PersistentVolumeGeneratorFunctionType = ./persistentVolumeGenerator.dhall

let configuration =
      { Type =
          { StatefulSet : StatefulSet.Type
          , PersistentVolumeGenerator :
              Optional PersistentVolumeGeneratorFunctionType
          }
      , default =
        { StatefulSet = StatefulSet.default
        , PersistentVolumeGenerator = None PersistentVolumeGeneratorFunctionType
        }
      }

in  configuration
