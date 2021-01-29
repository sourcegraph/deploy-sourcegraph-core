let DockerCompose/HealthCheck = ./healthcheck.dhall

let component =
      { Type =
          { container_name : Text
          , cpus : Double
          , environment : Optional (List Text)
          , healthcheck : Optional DockerCompose/HealthCheck.Type
          , image : Text
          , mem_limit : Text
          , networks : List Text
          , restart : Text
          , volumes : List Text
          }
      , default =
        { restart = "always"
        , networks = [ "sourcegraph" ]
        , healthcheck = None DockerCompose/HealthCheck.Type
        , volumes = [] : List Text
        , environment = None (List Text)
        }
      }

in  component
