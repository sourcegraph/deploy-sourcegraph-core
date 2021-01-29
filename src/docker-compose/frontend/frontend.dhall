let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let environment/toList = (./environment.dhall).environment/toList

let Simple/Frontend = ../../simple/frontend/package.dhall

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "sourcegraph-frontend-0"

        let environment = Some (environment/toList c.environment)

        let simple = Simple/Frontend.Containers.frontend

        let mountDir = simple.volumes.CACHE_DIR

        let image = util.Image/show c.image

        in  component::{
            , container_name = name
            , cpus = 4.0
            , mem_limit = "8g"
            , environment
            , healthcheck = Some c.healthcheck
            , image
            , volumes = [ "${name}:${mountDir}" ]
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
