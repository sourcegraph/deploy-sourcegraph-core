let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/grafana

let httpPort = { number = 3370, name = Some "http" }

let volumes =
      { grafanaData = "/var/lib/grafana"
      , datasources = "/sg_config_grafana/provisioning/datasources"
      , dashboards = "/sg_grafana_additional_dashboards"
      }

let grafanaContainer =
        Container::{ image }
      ∧ { name = "grafana", volumes, ports.httpPort = httpPort }

let Containers = { grafana = grafanaContainer }

in  { Containers }
