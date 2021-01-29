let util = ../../util/package.dhall

let simple = ../../simple/github-proxy/package.dhall

let configuration =
      { Type = { image : util.Image.Type }
      , default.image = simple.Containers.github-proxy.image
      }

in  configuration
