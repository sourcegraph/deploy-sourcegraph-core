let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Container/Jaeger = ./jaeger.dhall

let Container/RepoUpdater = ./containers/repo-updater.dhall

let Containers =
      { repo-updater : Container/RepoUpdater, jaeger : Container/Jaeger }

let Configuration =
      { namespace : Optional Text
      , Containers : Containers
      , sideCars : List Kubernetes/Container.Type
      }

in  Configuration
