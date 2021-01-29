let util = ../../util/package.dhall

let Simple/Gitserver =
      (../../simple/gitserver/package.dhall).Containers.gitserver

let environment = (./environment.dhall).environment

let configuration =
      { Type =
          { image : util.Image.Type
          , replicas : Natural
          , environment : environment.Type
          }
      , default =
        { environment = environment.default
        , image = Simple/Gitserver.image
        , replicas = 1
        }
      }

in  { configuration }
