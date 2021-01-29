let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let environment/toList = (./environment.dhall).environment/toList

let Simple/IndexedSearch = ../../simple/indexed-search/package.dhall

let component = ../schemas/component.dhall

let generateWebserver
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "zoekt-webserver-0"

        let environment = Some (environment/toList c.environment)

        let simple = Simple/IndexedSearch.Containers.webserver

        let mountDir = simple.volumes.data

        let image = util.Image/show c.webserverImage

        in  component::{
            , container_name = name
            , cpus = 4.0
            , mem_limit = "8g"
            , environment
            , healthcheck = Some c.healthcheck
            , image
            , volumes = [ "${name}:${mountDir}" ]
            }

let generateIndexserver
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "zoekt-indexserver-0"

        let environment = Some (environment/toList c.environment)

        let simple = Simple/IndexedSearch.Containers.indexserver

        let mountDir = simple.volumes.data

        let image = util.Image/show c.indexserverImage

        in  component::{
            , container_name = name
            , cpus = 4.0
            , mem_limit = "8g"
            , environment
            , image
            , volumes = [ "${name}:${mountDir}" ]
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generateWebserver c, generateIndexserver c ]

in  toList
