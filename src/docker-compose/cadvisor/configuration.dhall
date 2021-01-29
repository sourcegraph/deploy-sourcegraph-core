let util = ../../util/package.dhall

let Simple/CAdvisor = (../../simple/cadvisor/package.dhall).Containers.cadvisor

let configuration =
      { Type =
          { image : util.Image.Type, additionalVolumes : Optional (List Text) }
      , default.image = Simple/CAdvisor.image
      , additionalVolumes = None
      }

in  { configuration }
