let Volumes/show
    : ∀(name : Text) → ∀(mountPath : Text) → Text
    = λ(name : Text) → λ(mountPath : Text) → "${name}:${mountPath}"

let example0 = assert : Volumes/show "foo" "/bar" ≡ "foo:/bar"

let example1 = assert : Volumes/show "foo" "bar/" ≡ "foo:bar/"

let example2 = assert : Volumes/show "foo" "/bar/" ≡ "foo:/bar/"

let example3 = assert : Volumes/show "foo" "bar" ≡ "foo:bar"

let example4 = assert : Volumes/show "foo" "" ≡ "foo:"

let example5 = assert : Volumes/show "f/oo" "/" ≡ "f/oo:/"

in  Volumes/show
