let Simple/CAdvisor/Containers =
      (../../../../simple/cadvisor/package.dhall).Containers

let Image = (../../../../util/package.dhall).Image

let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let DaemonSet/CAdvisorContainer =
      { Type =
          { image : Image.Type
          , resources : Configuration/ResourceRequirements.Type
          , additionalArgs : List Text
          }
      , default =
        { image = Simple/CAdvisor/Containers.cadvisor.image
        , resources =
            Configuration/ResourceRequirements::{=}
          with limits.cpu = Some "300m"
          with limits.memory = Some "2000Mi"
          with requests.cpu = Some "150m"
          with requests.memory = Some "200Mi"
        , additionalArgs = [] : List Text
        }
      }

let DaemonSet/Containers =
      { Type = { cadvisor : DaemonSet/CAdvisorContainer.Type }
      , default.cadvisor = DaemonSet/CAdvisorContainer.default
      }

let DaemonSet =
      { Type = { Containers : DaemonSet/Containers.Type }
      , default.Containers = DaemonSet/Containers.default
      }

let configuration =
      { Type = { DaemonSet : DaemonSet.Type }
      , default.DaemonSet = DaemonSet.default
      }

in  configuration
