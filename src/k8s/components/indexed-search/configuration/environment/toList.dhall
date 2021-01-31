let Kubernetes/EnvVar =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let envVar/toList = ../../../../util/functions/environment-to-list.dhall

let environment = ./environment.dhall

let toList
    : ∀(e : environment.Type) → List Kubernetes/EnvVar.Type
    = λ(e : environment.Type) →
        envVar/toList
          (toMap e : List { mapKey : Text, mapValue : Kubernetes/EnvVar.Type })

in  toList
