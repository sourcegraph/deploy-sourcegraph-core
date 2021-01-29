let util = ../../util/package.dhall

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let Simple/IndexedSearch =
      (../../simple/indexed-search/package.dhall).Containers

let environment = (./environment.dhall).environment

let configuration =
      { Type =
          { webserverImage : util.Image.Type
          , indexserverImage : util.Image.Type
          , replicas : Natural
          , environment : environment.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default =
        { environment = environment.default
        , webserverImage = Simple/IndexedSearch.webserver.image
        , indexserverImage = Simple/IndexedSearch.indexserver.image
        , replicas = 1
        , healthcheck =
            util.HealthCheck/toDockerCompose
              Simple/IndexedSearch.webserver.HealthCheck
        }
      }

in  { configuration }
