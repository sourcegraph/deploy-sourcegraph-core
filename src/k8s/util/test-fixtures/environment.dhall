let Kubernetes/EnvVar =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/SecretKeySelector =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.SecretKeySelector.dhall

let selector =
      Kubernetes/SecretKeySelector::{
      , key = "TeSt_KeY"
      , name = Some "TeSt_NaMe"
      , optional = Some True
      }

let Secret =
      Kubernetes/EnvVar::{
      , name = "MY_TEST_ENV_VAR_WITH_SECRET"
      , valueFrom = Some Kubernetes/EnvVarSource::{
        , secretKeyRef = Some selector
        }
      }

let Foo = Kubernetes/EnvVar::{ name = "FOO", value = Some "foo" }

let Bar = Kubernetes/EnvVar::{ name = "BAR", value = Some "bar" }

let Gus = Kubernetes/EnvVar::{ name = "GUS", value = Some "gus" }

in  { Secret, Foo, Bar, Gus }
