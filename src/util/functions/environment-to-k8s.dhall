let Kubernetes/EnvVar = ../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let UserEnv = { name : Text, value : Text }

let UserEnv/tok8s
    : ∀(envTuple : UserEnv) → Kubernetes/EnvVar.Type
    = λ(envTuple : UserEnv) →
        Kubernetes/EnvVar::{ name = envTuple.name, value = Some envTuple.value }

let example0 =
        assert
      :   UserEnv/tok8s { name = "fooKey", value = "fooValue" }
        ≡ Kubernetes/EnvVar::{ name = "fooKey", value = Some "fooValue" }

in  UserEnv/tok8s
