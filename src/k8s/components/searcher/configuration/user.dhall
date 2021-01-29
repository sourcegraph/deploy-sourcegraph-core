let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/Searcher/Containers =
      (../../../../simple/searcher/package.dhall).Containers

let environment = ./environment/environment.dhall

let volumes = ./volumes/volumes.dhall

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

let searcherResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "2"
      with limits.memory = Some "2G"
      with requests.cpu = Some "500m"
      with requests.memory = Some "500M"

let SearcherContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Searcher/Containers.searcher.image
        , resources = searcherResources
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
          { searcher : SearcherContainer.Type, jaeger : JaegerContainer.Type }
      , default =
        { searcher = SearcherContainer.default
        , jaeger = JaegerContainer.default
        }
      }

let Deployment =
      { Type =
          { replicas : Natural
          , Containers : Containers.Type
          , volumes : volumes.Type
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { replicas = 1
        , Containers = Containers.default
        , volumes = volumes.default
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let configuration =
      { Type = { Deployment : Deployment.Type }
      , default.Deployment = Deployment.default
      }

in  configuration
