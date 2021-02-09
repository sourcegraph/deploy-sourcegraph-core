let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let jaegerImage = Simple/images.sourcegraph/jaeger-all-in-one

let ports =
      { query = 6072
      , collector = 14250
      , agent = { A = 5778, B = 6831, C = 6832 }
      }

let jaegerContainer =
      Container::{ image = jaegerImage } ∧ { name = "jaeger", ports }

let Containers = { jaeger = jaegerContainer }

in  { Containers }
