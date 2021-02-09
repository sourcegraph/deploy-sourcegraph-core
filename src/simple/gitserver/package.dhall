let util = ../../util/package.dhall

let Container = util.Container

let Simple/images = ../images.dhall

let image = Simple/images.sourcegraph/gitserver

let ports = { rpc = { number = 3178, name = Some "rpc" } }

let reposDir = "/data/repos"

let volumes = { repos = reposDir }

let gitserverContainer =
        Container::{ image }
      ∧ { volumes, name = "gitserver", ports.rpc = ports.rpc }

let Containers = { gitserver = gitserverContainer }

in  { Containers }
