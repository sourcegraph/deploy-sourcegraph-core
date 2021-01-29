let util = ../../util/package.dhall

let EnvVar = util.EnvVar

let envVar/toList = ../../util/functions/environment-to-list.dhall

let Simple/Frontend = ../../simple/frontend/package.dhall

let SRC_FRONTEND_INTERNAL = Simple/Frontend.SRC_FRONTEND_INTERNAL

let environment =
      { Type =
          { DEPLOY_TYPE : EnvVar.Type
          , GOMAXPROCS : EnvVar.Type
          , JAEGER_AGENT_HOST : EnvVar.Type
          , SRC_FRONTEND_INTERNAL : EnvVar.Type
          }
      , default =
        { DEPLOY_TYPE = EnvVar::{
          , name = "DEPLOY_TYPE"
          , value = Some "docker-compose"
          }
        , GOMAXPROCS = EnvVar::{ name = "GOMAXPROCS", value = Some "4" }
        , JAEGER_AGENT_HOST = EnvVar::{
          , name = "JAEGER_AGENT_HOST"
          , value = Some "jaeger"
          }
        , SRC_FRONTEND_INTERNAL = EnvVar::{
          , name = "SRC_FRONTEND_INTERNAL"
          , value = Some SRC_FRONTEND_INTERNAL
          }
        }
      }

let environment/toList
    : ∀(e : environment.Type) → List Text
    = λ(e : environment.Type) → envVar/toList (toMap e)

in  { environment, environment/toList }
