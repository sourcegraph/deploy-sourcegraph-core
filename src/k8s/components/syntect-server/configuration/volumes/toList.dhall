let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let volumes = ./volumes.dhall

let Map/values =
      https://prelude.dhall-lang.org/v18.0.0/Map/values.dhall sha256:ae02cfb06a9307cbecc06130e84fd0c7b96b7f1f11648961e1b030ec00940be8

let toList
    : ∀(v : volumes.Type) → List Kubernetes/Volume.Type
    = λ(v : volumes.Type) → Map/values Text Kubernetes/Volume.Type (toMap v)

in  toList
