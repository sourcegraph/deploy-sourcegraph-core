let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/github-proxy"
      , tag = "insiders"
      , digest = Some
          "c2942b35049793a0f52fc123d5287f56d3a59082ad579e1e697bed2c05a06572"
      }

let hostname = "github-proxy"

let ports = { http = { number = 3180, name = Some "http" } }

let githubProxyContainer =
      Container::{ image } ∧ { name = hostname, hostname, ports }

let Containers = { github-proxy = githubProxyContainer }

in  { Containers }
