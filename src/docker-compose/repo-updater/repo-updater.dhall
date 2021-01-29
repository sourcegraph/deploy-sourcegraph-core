let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let environment/toList = (./environment.dhall).environment/toList

let Simple/RepoUpdater = ../../simple/repo-updater/package.dhall

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "repo-updater"

        let environment = Some (environment/toList c.environment)

        let simple = Simple/RepoUpdater.Containers.repo-updater

        let mountDir = simple.volumes.cache

        let image = util.Image/show c.image

        in  component::{
            , container_name = name
            , cpus = 4.0
            , mem_limit = "4g"
            , environment
            , healthcheck = Some c.healthcheck
            , image
            , volumes = [ "${name}:${mountDir}" ]
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
