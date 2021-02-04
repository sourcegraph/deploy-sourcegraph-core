let Kubernetes/VolumeMount =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Lights =
      Kubernetes/VolumeMount::{
      , name = "FAKE_VOLUME_LOL"
      , mountPath = "/your/name/should/be/in/lights"
      }

let MaybeNot =
      Kubernetes/VolumeMount::{
      , name = "FAKE_MAYBE_NOT"
      , mountPath = "/perhaps/not"
      }

in  { Lights, MaybeNot }
