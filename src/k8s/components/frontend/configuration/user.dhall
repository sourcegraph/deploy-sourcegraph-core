let JaegerImage = (../../shared/jaeger/defaults.dhall).Image

let ContainerConfiguration = (../../shared/shared.dhall).ContainerConfiguration

let Simple/Frontend/Containers =
      (../../../../simple/frontend/package.dhall).Containers

let environment = ./environment/environment.dhall

let FrontendContainer =
      { Type = ContainerConfiguration.Type ⩓ { Environment : environment.Type }
      , default =
            ContainerConfiguration.default
          ⫽ { Environment = environment.default
            , image = Simple/Frontend/Containers.frontend.image
            }
      }

let JaegerContainer = ContainerConfiguration with default.image = JaegerImage

let Containers =
      { Type =
          { frontend : FrontendContainer.Type, jaeger : JaegerContainer.Type }
      , default =
        { frontend = FrontendContainer.default
        , jaeger = JaegerContainer.default
        }
      }

let Deployment =
      { Type = { Containers : Containers.Type }
      , default.Containers = Containers.default
      }

let configuration =
      { Type = { Deployment : Deployment.Type }
      , default.Deployment = Deployment.default
      }

in  configuration
