let Kubernetes/EnvVar =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/Container =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Simple/GithubProxy/Containers =
      (../../../../simple/github-proxy/package.dhall).Containers

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

let GithubProxyResources
    : Configuration/ResourceRequirements.Type
    = Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "1"
      with limits.memory = Some "1G"
      with requests.cpu = Some "100m"
      with requests.memory = Some "250M"

let GithubProxyContainer =
      { Type =
            ContainerConfiguration.Type
          ⩓ { environment : environment.Type
            , additionalEnvVars : List Kubernetes/EnvVar.Type
            , additionalVolumeMounts : List Kubernetes/VolumeMount.Type
            }
      , default =
        { environment = environment.default
        , image = Simple/GithubProxy/Containers.github-proxy.image
        , resources = GithubProxyResources
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
          { github-proxy : GithubProxyContainer.Type
          , jaeger : JaegerContainer.Type
          }
      , default =
        { github-proxy = GithubProxyContainer.default
        , jaeger = JaegerContainer.default
        }
      }

let Deployment =
      { Type =
          { Containers : Containers.Type
          , additionalSideCars : List Kubernetes/Container.Type
          }
      , default =
        { Containers = Containers.default
        , additionalSideCars = [] : List Kubernetes/Container.Type
        }
      }

let configuration =
      { Type = { Deployment : Deployment.Type }
      , default.Deployment = Deployment.default
      }

in  configuration
