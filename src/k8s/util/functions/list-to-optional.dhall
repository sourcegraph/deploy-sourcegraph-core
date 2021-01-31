let List/null =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v20.1.0/Prelude/List/null.dhall sha256:2338e39637e9a50d66ae1482c0ed559bbcc11e9442bfca8f8c176bbcd9c4fc80

let f
    : ∀(T : Type) → ∀(xs : List T) → Optional (List T)
    = λ(T : Type) →
      λ(xs : List T) →
        if List/null T xs then None (List T) else Some xs

let exampleO = assert : f Text [ "foo", "bar" ] ≡ Some [ "foo", "bar" ]

let example1 = assert : f Text ([] : List Text) ≡ None (List Text)

in  f
