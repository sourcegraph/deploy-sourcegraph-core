let Kubernetes/ObjectMeta =
      ../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/ConfigMap =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let Configuration/Internal/ConfigMap = ../configuration/internal/configmap.dhall

let k8s/util = ../../../util/package.dhall

let ConfigMap/generate
    : ∀(c : Configuration/Internal/ConfigMap) → Kubernetes/ConfigMap.Type
    = λ(c : Configuration/Internal/ConfigMap) →
        let name = "codeintel-db-conf"

        let namespace = c.namespace

        let annotations = toMap { description = "Configuration for PostgreSQL" }

        let labels =
              toMap
                (   k8s/util.Labels.deploySourcegraph
                  ∧ k8s/util.Labels.noClusterAdmin
                )

        let data = toMap { `postgresql.conf` = c.data.`codeintel-db.conf` }

        in  Kubernetes/ConfigMap::{
            , metadata = Kubernetes/ObjectMeta::{
              , name = Some name
              , namespace
              , annotations = Some annotations
              , labels = Some labels
              }
            , data = Some data
            }

in  ConfigMap/generate
