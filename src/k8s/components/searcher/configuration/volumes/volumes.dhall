let Kubernetes/Volume =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let CacheSSDVolume = (../../../../util/package.dhall).Volumes.cacheSSDVolume

let volumes =
      { Type = { cache-ssd : Kubernetes/Volume.Type }
      , default.cache-ssd = CacheSSDVolume
      }

in  volumes
