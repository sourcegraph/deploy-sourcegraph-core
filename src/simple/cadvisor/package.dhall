let util = ../../util/package.dhall

let Simple/images = ../images.dhall

let Container = util.Container

let image = Simple/images.sourcegraph/cadvisor

let httpPort = { number = 48080, name = Some "http" }

let volumes =
      { rootFs = { mountPath = "/rootfs", hostPath = "/" }
      , var-run = { mountPath = "/var/run", hostPath = "/var/run" }
      , sys = { mountPath = "/sys", hostPath = "/sys" }
      , docker = { mountPath = "/var/lib/docker", hostPath = "/var/lib/docker" }
      , disk = { mountPath = "/dev/disk", hostPath = "/dev/disk" }
      }

let cadvisorContainer =
        Container::{ image }
      ∧ { name = "cadvisor", volumes, ports.httpPort = httpPort }

let Containers = { cadvisor = cadvisorContainer }

in  { Containers }
