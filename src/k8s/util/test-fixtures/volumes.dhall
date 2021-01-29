let Kubernetes/Volume =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/NFSVolumeSource =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.NFSVolumeSource.dhall

let nfs =
      Kubernetes/NFSVolumeSource::{
      , path = "TEST_PATH"
      , server = "my.testing.server.io"
      , readOnly = Some False
      }

let NFS = Kubernetes/Volume::{ name = "TeSt-VoLuMe", nfs = Some nfs }

in  { NFS }
