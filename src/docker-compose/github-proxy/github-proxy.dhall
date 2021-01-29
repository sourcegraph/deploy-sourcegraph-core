let configuration = ./configuration.dhall

let component = ../schemas/component.dhall

let util = ../../util/package.dhall

let Simple/github-proxy = ../../simple/github-proxy/package.dhall

let Simple/frontend = ../../simple/frontend/package.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = Simple/github-proxy.Containers.github-proxy.name

        let image = util.Image/show c.image

        in  component::{
            , container_name = name
            , image
            , mem_limit = "1g"
            , cpus = 1.0
            , environment = Some
              [ "GOMAXPROCS=1"
              , "SRC_FRONTEND_INTERNAL=${Simple/frontend.SRC_FRONTEND_INTERNAL}"
              , "JAEGER_AGENT_HOST=jaeger"
              ]
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
