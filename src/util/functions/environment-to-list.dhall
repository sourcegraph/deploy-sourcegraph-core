let util = ../package.dhall

let EnvVar = util.EnvVar

let envVar/show = ./environment-show.dhall

let Map/values =
      https://prelude.dhall-lang.org/v18.0.0/Map/values.dhall sha256:ae02cfb06a9307cbecc06130e84fd0c7b96b7f1f11648961e1b030ec00940be8

let List/unpackOptionals =
      https://prelude.dhall-lang.org/v18.0.0/List/unpackOptionals.dhall sha256:0cbaa920f429cf7fc3907f8a9143203fe948883913560e6e1043223e6b3d05e4

let List/map =
      https://prelude.dhall-lang.org/v18.0.0/List/map.dhall sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let envVar/toList
    : ∀(e : List { mapKey : Text, mapValue : EnvVar.Type }) → List Text
    = λ(e : List { mapKey : Text, mapValue : EnvVar.Type }) →
        let envList = Map/values Text EnvVar.Type e

        let optionalTextList =
              List/map EnvVar.Type (Optional Text) envVar/show envList

        in  List/unpackOptionals Text optionalTextList

in  envVar/toList
