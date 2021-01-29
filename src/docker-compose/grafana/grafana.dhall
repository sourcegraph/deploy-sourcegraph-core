let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let simple/grafana = (../../simple/grafana/package.dhall).Containers.grafana

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "grafana"

        let image = util.Image/show c.image

        let grafanaData = simple/grafana.volumes.grafanaData

        let datasources = simple/grafana.volumes.datasources

        let dashboards = simple/grafana.volumes.dashboards

        in  component::{
            , container_name = name
            , cpus = 1.0
            , mem_limit = "1g"
            , image
            , environment = None (List Text)
            , volumes =
              [ "${name}:${grafanaData}"
              , "../grafana/datasources:${datasources}"
              , "../grafana/dashboards:${dashboards}"
              ]
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
