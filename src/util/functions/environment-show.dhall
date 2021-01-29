let util = ../package.dhall

let EnvVar = util.EnvVar

let envVar/show
    : ∀(e : EnvVar.Type) → Optional Text
    = λ(e : EnvVar.Type) →
        merge
          { None = None Text
          , Some = λ(value : Text) → Some "${e.name}=${value}"
          }
          e.value

in  envVar/show
