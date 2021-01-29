let Kubernetes/SecurityContext =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/SELinuxOptions =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.SELinuxOptions.dhall

let seLinuxOptions =
      Kubernetes/SELinuxOptions::{
      , level = Some "TeStlEveL"
      , role = Some "mBRzv7RCq4"
      , type = None Text
      , user = Some "p9gdW2opH7"
      }

let SELinux =
      Some
        Kubernetes/SecurityContext::{
        , privileged = Some False
        , seLinuxOptions = Some seLinuxOptions
        , runAsGroup = Some 42222
        }

let Empty = None Kubernetes/SecurityContext.Type

in  { SELinux, Empty }
