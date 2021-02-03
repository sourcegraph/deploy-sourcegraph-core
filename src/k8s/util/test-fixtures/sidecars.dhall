let Kubernetes/Container =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/EnvVar =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Foo =
      Kubernetes/Container::{
      , args = Some [ "bash", "-c", "echo 'hello world'" ]
      , env = Some [ Kubernetes/EnvVar::{ name = "FOO", value = Some "BAR" } ]
      , image = Some "index.docker.io/your/image:tag@sha256:123456"
      , name = "sidecar"
      }

let Baz =
      Kubernetes/Container::{
      , env = Some [ Kubernetes/EnvVar::{ name = "Baz", value = Some "BAR" } ]
      , image = Some "index.docker.io/your/image:tag-2@sha256:123456"
      , name = "baz-sidecar"
      }

in  { Foo, Baz }
