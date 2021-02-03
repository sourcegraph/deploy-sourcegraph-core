let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/grafana"
      , tag = "insiders"
      , digest = Some
          "a176f43202b0be8ee891452ee454515da93baee7d173ede4c9a8a5bc18d91a3d"
      }

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
