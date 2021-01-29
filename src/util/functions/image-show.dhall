let Optional/default =
      https://prelude.dhall-lang.org/v18.0.0/Optional/default.dhall sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Optional/map =
      https://prelude.dhall-lang.org/v18.0.0/Optional/map.dhall sha256:501534192d988218d43261c299cc1d1e0b13d25df388937add784778ab0054fa

let Image = (../schemas.dhall).Image

let Image/show =
      λ(i : Image.Type) →
        let digest =
              Optional/default
                Text
                ""
                (Optional/map Text Text (λ(d : Text) → "@sha256:${d}") i.digest)

        let registry =
              Optional/default
                Text
                ""
                (Optional/map Text Text (λ(r : Text) → "${r}/") i.registry)

        in  "${registry}${i.name}:${i.tag}${digest}"

let exampleImage = Image::{ name = "sourcegraph/frontend", tag = "insiders" }

let example0 =
        assert
      :   Image/show exampleImage
        ≡ "index.docker.io/sourcegraph/frontend:insiders"

let example1 =
        assert
      :   Image/show (exampleImage with registry = None Text)
        ≡ "sourcegraph/frontend:insiders"

let example2 =
        assert
      :   Image/show
            (exampleImage with registry = None Text with digest = Some "123tsf")
        ≡ "sourcegraph/frontend:insiders@sha256:123tsf"

let example3 =
        assert
      :   Image/show (exampleImage with digest = Some "123tsf")
        ≡ "index.docker.io/sourcegraph/frontend:insiders@sha256:123tsf"

let example4 =
        assert
      :   Image/show
            ( exampleImage
              with registry = Some "index.sourcegraph.net"
              with digest = Some "123tsf"
            )
        ≡ "index.sourcegraph.net/sourcegraph/frontend:insiders@sha256:123tsf"

in  { Image/show }
