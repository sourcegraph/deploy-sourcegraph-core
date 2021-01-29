let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let Simple/Minio = (../../simple/minio/package.dhall).Containers.minio

let Volume/show = ../functions/volumes-show.dhall

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "minio"

        let image = util.Image/show c.image

        let volume =
              Volume/show "minio-data" "${Simple/Minio.volumes.minio-data}/"

        let healthcheck =
              util.HealthCheck/toDockerCompose Simple/Minio.HealthCheck

        in  component::{
            , container_name = name
            , cpus = 1.0
            , mem_limit = "500M"
            , environment = None (List Text)
            , volumes = [ volume ]
            , healthcheck = Some healthcheck
            , image
            }

in  generate
