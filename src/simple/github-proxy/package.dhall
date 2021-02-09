let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/github-proxy

let hostname = "github-proxy"

let ports = { http = { number = 3180, name = Some "http" } }

let githubProxyContainer =
      Container::{ image } ∧ { name = hostname, hostname, ports }

let Containers = { github-proxy = githubProxyContainer }

in  { Containers }
