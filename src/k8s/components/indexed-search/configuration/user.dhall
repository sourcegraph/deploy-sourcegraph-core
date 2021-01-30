let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/Indexed-Search/Containers =
      (../../../../simple/indexed-search/package.dhall).Containers

let environment = ./environment/environment.dhall

let util = ../../../../util/package.dhall

let Image = util.Image

let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let ContainerConfiguration =
      { Type =
          { image : Image.Type
          , resources : Configuration/ResourceRequirements.Type
          }
      , default = {=}
      }

let zoekt-indexserverResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "2"
      with limits.memory = Some "2G"
      with requests.cpu = Some "500m"
      with requests.memory = Some "500M"

let zoekt-webserverResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "2"
      with limits.memory = Some "2G"
      with requests.cpu = Some "500m"
      with requests.memory = Some "500M"

let Zoekt-IndexserverContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Indexed-Search/Containers.indexserver.image
        , resources = zoekt-indexserverResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let Zoekt-WebserverContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/Indexed-Search/Containers.webserver.image
        , resources = zoekt-webserverResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let Containers =
      { Type =
          { zoekt-indexserver : Zoekt-IndexserverContainer.Type
          , zoekt-webserver : Zoekt-WebserverContainer.Type
          }
      , default =
        { zoekt-indexserver = Zoekt-IndexserverContainer.default
        , zoekt-webserver = Zoekt-WebserverContainer.default
        }
      }

let StatefulSet =
      { Type =
          { replicas : Natural
          , Containers : Containers.Type
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { replicas = 1
        , Containers = Containers.default
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
