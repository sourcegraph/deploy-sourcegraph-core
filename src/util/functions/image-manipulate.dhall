let Optional/default =
      https://prelude.dhall-lang.org/v18.0.0/Optional/default.dhall sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Image = (../schemas.dhall).Image

let options =
      { Type =
          { tagPrefix : Optional Text
          , tagSuffix : Optional Text
          , tag : Optional Text
          , stripDigest : Bool
          , registry : Optional Text
          }
      , default =
        { tagPrefix = None Text
        , tagSuffix = None Text
        , tag = None Text
        , stripDigest = False
        , registry = None Text
        }
      }

let manipulate
    : ∀(o : options.Type) → ∀(i : Image.Type) → Image.Type
    = λ(o : options.Type) →
      λ(i : Image.Type) →
        let prefix = Optional/default Text "" o.tagPrefix

        let suffix = Optional/default Text "" o.tagSuffix

        let tag = "${prefix}${Optional/default Text i.tag o.tag}${suffix}"

        let digest = if o.stripDigest then None Text else i.digest

        let registry =
              merge
                { None = i.registry, Some = λ(r : Text) → Some r }
                o.registry

        in  i ⫽ { tag, digest, registry }

let baseImage = Image::{ name = "sourcegraph/frontend", tag = "insiders" }

let example0 =
        assert
      :   manipulate options::{ tagPrefix = Some "something-" } baseImage
        ≡ (baseImage with tag = "something-insiders")

let example1 =
        assert
      :   manipulate options::{ tagSuffix = Some "-something" } baseImage
        ≡ (baseImage with tag = "insiders-something")

let example2 =
        assert
      :   manipulate
            options::{
            , tagPrefix = Some "beginning-"
            , tagSuffix = Some "-ending"
            , tag = Some "middle"
            }
            baseImage
        ≡ (baseImage with tag = "beginning-middle-ending")

let example3 =
        assert
      :   manipulate
            options::{ stripDigest = True }
            (baseImage with digest = Some "abc123")
        ≡ baseImage

let example4 =
        assert
      :   manipulate
            options::{
            , stripDigest = True
            , registry = Some "this.other.registry"
            , tagPrefix = Some "beginning-"
            }
            (baseImage with digest = Some "abc123")
        ≡ ( baseImage
            with tag = "beginning-insiders"
            with registry = Some "this.other.registry"
          )

let example5 = assert : manipulate options::{=} baseImage ≡ baseImage

in  { Image/manipulate = manipulate, Image/manipulate/options = options }
