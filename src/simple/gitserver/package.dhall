let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/gitserver"
      , tag = "insiders"
      , digest = Some
          "0a5b2b0171c426442e7138d0c0e2d4a9bcf007a14066c6573fcf371ec1e3283d"
      }

let httpPort = 3178

let reposDir = "/data/repos"

let volumes = { repos = reposDir }

let gitserverContainer =
        Container::{ image }
      ∧ { volumes, name = "gitserver", ports.rpc = httpPort }

let Containers = { gitserver = gitserverContainer }

in  { Containers }
