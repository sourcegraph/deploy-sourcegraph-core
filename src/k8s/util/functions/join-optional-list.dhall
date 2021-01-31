let Optional/default =
      https://prelude.dhall-lang.org/v18.0.0/Optional/default.dhall sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let listToOptional = ./list-to-optional.dhall

let f
    : ∀(T : Type) →
      ∀(xs : Optional (List T)) →
      ∀(ys : Optional (List T)) →
        Optional (List T)
    = λ(T : Type) →
      λ(xs : Optional (List T)) →
      λ(ys : Optional (List T)) →
        let myXs = Optional/default (List T) ([] : List T) xs

        let myYs = Optional/default (List T) ([] : List T) ys

        in  listToOptional T (myXs # myYs)

let someFoo = Some [ "foo" ]

let someBar = Some [ "bar" ]

let emptyList = Some ([] : List Text)

let noneList = None (List Text)

let exampleO = assert : f Text someFoo someBar ≡ Some [ "foo", "bar" ]

let example1 = assert : f Text someFoo emptyList ≡ someFoo

let example2 = assert : f Text someFoo noneList ≡ someFoo

let example3 = assert : f Text noneList someBar ≡ someBar

let example4 = assert : f Text emptyList someBar ≡ someBar

let example5 = assert : f Text noneList noneList ≡ noneList

let example6 = assert : f Text emptyList emptyList ≡ noneList

in  f
