let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "precise-code-intel-worker"

        let image = util.Image/show c.image

        in  component::{
            , container_name = name
            , cpus = 2.0
            , mem_limit = "4g"
            , environment = Some
              [ "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090" ]
            , image
            , healthcheck = Some c.healthcheck
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
