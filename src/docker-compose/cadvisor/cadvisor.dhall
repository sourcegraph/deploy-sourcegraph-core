let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let simple/cadvisor = (../../simple/cadvisor/package.dhall).Containers.cadvisor

let component = ../schemas/component.dhall

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let v = simple/cadvisor.volumes

        let defaultVolumes =
              [ "${v.rootFs.hostPath}:${v.rootFs.mountPath}:ro"
              , "${v.var-run.hostPath}:${v.var-run.mountPath}:ro"
              , "${v.var-run.hostPath}:${v.var-run.mountPath}:ro"
              , "${v.var-run.hostPath}:${v.var-run.mountPath}:ro"
              , "${v.var-run.hostPath}:${v.var-run.mountPath}:ro"
              ]

        in  component::{
            , container_name = "cadvisor"
            , cpus = 1.0
            , mem_limit = "1g"
            , image = util.Image/show c.image
            , environment = None (List Text)
            , volumes =
                merge
                  { Some =
                      λ(additionalVolumes : List Text) →
                        defaultVolumes # additionalVolumes
                  , None = defaultVolumes
                  }
                  c.additionalVolumes
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
