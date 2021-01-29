let Simple/Containers = (../../../../simple/minio/package.dhall).Containers

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

let Resources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "1"
      with limits.memory = Some "500M"
      with requests.cpu = Some "1"
      with requests.memory = Some "500M"

let Container =
      { Type = ContainerConfiguration.Type ⩓ { environment : environment.Type }
      , default =
        { image = Simple/Containers.minio.image
        , resources = Resources
        , environment = environment.default
        }
      }

let Containers =
      { Type = { minio : Container.Type }, default.minio = Container.default }

let Deployment =
      { Type = { Containers : Containers.Type }
      , default.Containers = Containers.default
      }

let PersistentVolumeClaimResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with requests.storage = Some "100Gi"

let PersistentVolumeClaim =
      { Type =
          { name : Text, resources : Configuration/ResourceRequirements.Type }
      , default = { name = "minio", resources = PersistentVolumeClaimResources }
      }

let configuration =
      { Type =
          { Deployment : Deployment.Type
          , PersistentVolumeClaim : PersistentVolumeClaim.Type
          }
      , default.Deployment = Deployment.default
      , default.PersistentVolumeClaim = PersistentVolumeClaim.default
      }

in  configuration
