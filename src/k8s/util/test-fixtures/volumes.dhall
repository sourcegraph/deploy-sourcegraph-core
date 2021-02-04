let Kubernetes/Volume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/NFSVolumeSource =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.NFSVolumeSource.dhall

let Kubernetes/HostPathVolumeSource =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.HostPathVolumeSource.dhall

let nfs =
      Kubernetes/NFSVolumeSource::{
      , path = "TEST_PATH"
      , server = "my.testing.server.io"
      , readOnly = Some False
      }

let NFS = Kubernetes/Volume::{ name = "TeSt-VoLuMe", nfs = Some nfs }

let Foo =
      Kubernetes/Volume::{
      , name = "TeSt-VoLuMe-2"
      , hostPath = Some Kubernetes/HostPathVolumeSource::{ path = "foo/bar" }
      }

in  { NFS, Foo }
