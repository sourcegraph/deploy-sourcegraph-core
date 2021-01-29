let Util/Image = ../../../util/image.dhall

let Image/manipluate/options =
      (../../../util/functions/image-manipulate.dhall).Image/manipulate/options

let imageTag = "some-tag"

let name = "TEST_USER/TEST_NAME"

let registry = "my.registry.com"

let digest = "abc123DEADBEEF"

let BaseImage =
      Util/Image::{
      , name
      , registry = Some registry
      , digest = Some digest
      , tag = imageTag
      }

let baseShow = "${registry}/${name}:${imageTag}@sha256:${digest}"

let prefix = "my-prefix!"

let ManipulateOptions =
      Image/manipluate/options::{ stripDigest = True, tagPrefix = Some prefix }

let prefixedTag = "${prefix}${imageTag}"

let ManipulatedImage = BaseImage with digest = None Text with tag = prefixedTag

let ManipulatedShow = "${registry}/${name}:${prefixedTag}@sha256:${digest}"

let Image =
      { Base = BaseImage
      , BaseShow = baseShow
      , ManipulateOptions
      , Manipulated = ManipulatedImage
      , ManipulatedShow
      }

in  Image
