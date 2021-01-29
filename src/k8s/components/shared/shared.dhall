let Image = (../../../util/package.dhall).Image

let ContainerConfiguration = { Type = { image : Image.Type }, default = {=} }

in  { ContainerConfiguration }
