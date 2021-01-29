let Kubernetes/AllowedHostPath =
      ../../../../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.AllowedHostPath.dhall

let config =
      { namespace : Optional Text
      , allowedHostPaths : List Kubernetes/AllowedHostPath.Type
      }

in  config
