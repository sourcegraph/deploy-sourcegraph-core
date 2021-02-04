let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/PreciseCodeIntelWorker/Container =
      (../../../../simple/precise-code-intel/package.dhall).Containers

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

let preciseCodeIntelWorkerResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "2"
      with limits.memory = Some "4G"
      with requests.cpu = Some "500m"
      with requests.memory = Some "2G"

let preciseCodeIntelWorkerContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/PreciseCodeIntelWorker/Container.preciseCodeIntel.image
        , resources = preciseCodeIntelWorkerResources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        }
      }

let Containers =
      { Type = { precise-code-intel : preciseCodeIntelWorkerContainer.Type }
      , default.precise-code-intel = preciseCodeIntelWorkerContainer.default
      }

let Deployment =
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

let configuration =
      { Type = { Deployment : Deployment.Type }
      , default.Deployment = Deployment.default
      }

in  configuration
