let types = ./types.dhall

let Image =
      { Type = types.Image
      , default = { registry = Some "index.docker.io", digest = None Text }
      }

in  Image
