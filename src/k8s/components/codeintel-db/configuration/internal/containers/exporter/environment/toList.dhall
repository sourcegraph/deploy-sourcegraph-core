let Map/values =
      https://prelude.dhall-lang.org/v18.0.0/Map/values.dhall sha256:ae02cfb06a9307cbecc06130e84fd0c7b96b7f1f11648961e1b030ec00940be8

let Kubernetes/EnvVar =
      ../../../../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let environment = ./environment.dhall

let toList
    : ∀(e : environment.Type) → List Kubernetes/EnvVar.Type
    = λ(e : environment.Type) → Map/values Text Kubernetes/EnvVar.Type (toMap e)

in  toList
