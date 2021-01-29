let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/cadvisor"
      , tag = "insiders"
      , digest = Some
          "da8fa91d4e06bdcd430ceb5e719f63339a5ff233471850bf16c7290cbb3630fd"
      }

let httpPort = 48080

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
