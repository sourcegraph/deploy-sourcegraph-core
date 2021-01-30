let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let jaegerImage =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/jaeger-all-in-one"
      , tag = "insiders"
      , digest = Some
          "4d7b14f09400931017aa1ab2565b9a5210613291f74d0fcaabf5446cbb727739"
      }

let ports =
      { query = 6072
      , collector = 14250
      , agent = { A = 5578, B = 6831, C = 6832 }
      }

let jaegerContainer =
      Container::{ image = jaegerImage } ∧ { name = "jaeger", ports }

let Containers = { jaeger = jaegerContainer }

in  { Containers }
