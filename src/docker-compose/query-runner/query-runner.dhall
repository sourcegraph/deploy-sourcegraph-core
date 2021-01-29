let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "query-runner"

        let image = util.Image/show c.image

        in  component::{
            , container_name = name
            , cpus = 1.0
            , mem_limit = "1g"
            , environment = Some
              [ "GOMAXPROCS=1"
              , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
              , "JAEGER_AGENT_HOST=jaeger"
              ]
            , volumes = [] : List Text
            , image
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
