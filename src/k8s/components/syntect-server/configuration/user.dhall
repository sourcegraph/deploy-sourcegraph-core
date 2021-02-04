let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Volume =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/syntect-server/Containers =
      (../../../../simple/syntect-server/package.dhall).Containers

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

let syntect-server/Resources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "4"
      with limits.memory = Some "6G"
      with requests.cpu = Some "250m"
      with requests.memory = Some "2G"

let syntect-server/Container =
      { Type =
            ContainerConfiguration.Type
          ⩓ { additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { image = Simple/syntect-server/Containers.syntect-server.image
        , resources = syntect-server/Resources
        , additionalEnvVars = [] : List Kubernetes/EnvVar.Type
        , additionalVolumeMounts = [] : List Kubernetes/VolumeMount.Type
        }
      }

let Containers =
      { Type = { syntect-server : syntect-server/Container.Type }
      , default.syntect-server = syntect-server/Container.default
      }

let Deployment =
      { Type =
          { Containers : Containers.Type
          , additionalSideCars : List Kubernetes/Container.Type
          , additionalVolumes : List Kubernetes/Volume.Type
          }
      , default =
        { Containers = Containers.default
        , additionalSideCars = [] : List Kubernetes/Container.Type
        , additionalVolumes = [] : List Kubernetes/Volume.Type
        }
      }

let configuration =
      { Type = { Deployment : Deployment.Type }
      , default.Deployment = Deployment.default
      }

in  configuration
