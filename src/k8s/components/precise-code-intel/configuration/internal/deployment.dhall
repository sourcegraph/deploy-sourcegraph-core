let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Container/PreciseCodeIntelWorker =
      ./containers/precise-code-intel-worker.dhall

let Containers =
      { precise-code-intel-worker : Container/PreciseCodeIntelWorker }

let DeploymentConfiguration =
      { namespace : Optional Text
      , Containers : Containers
      , sideCars : List Kubernetes/Container.Type
      }

in  DeploymentConfiguration
