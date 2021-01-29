let util = ../../util/package.dhall

let Simple/Grafana = (../../simple/grafana/package.dhall).Containers.grafana

let configuration =
      { Type = { image : util.Image.Type }
      , default.image = Simple/Grafana.image
      }

in  { configuration }
