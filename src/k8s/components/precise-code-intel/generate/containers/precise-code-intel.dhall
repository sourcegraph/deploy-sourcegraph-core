let Kubernetes/Probe =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/Container =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../../../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Simple/PreciseCodeIntel =
      ../../../../../simple/precise-code-intel/package.dhall

let util = ../../../../../util/package.dhall

let Configuration/Internal/Container/PreciseCodeIntel =
      ../../configuration/internal/containers/precise-code-intel-worker.dhall

let Containers/preciseCodeIntelWorker/generate
    : forall (c : Configuration/Internal/Container/PreciseCodeIntel) ->
        Kubernetes/Container.Type
    = \(c : Configuration/Internal/Container/PreciseCodeIntel) ->
        let image = util.Image/show c.image

        let resources = c.resources

        let securityContext = c.securityContext

        let simple/precise-code-intel =
              Simple/PreciseCodeIntel.Containers.preciseCodeIntel

        let k8sProbe =
              util.HealthCheck/tok8s simple/precise-code-intel.Healthcheck

        let probe = k8sProbe with failureThreshold = None Natural

        let livenessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = Some 60
              with timeoutSeconds = Some 5

        let readinessProbe
            : Kubernetes/Probe.Type
            = probe
              with initialDelaySeconds = None Natural
              with timeoutSeconds = Some 5
              with periodSeconds = Some 5

        let ports = simple/precise-code-intel.ports

        let httpPort =
              Kubernetes/ContainerPort::{
              , containerPort = ports.http
              , name = Some "http"
              }

        in  Kubernetes/Container::{
            , env = c.envVars
            , image = Some image
            , livenessProbe = Some livenessProbe
            , name = "precise-code-intel-worker"
            , ports = Some
              [ httpPort
              , Kubernetes/ContainerPort::{
                , containerPort = 6060
                , name = Some "debug"
                }
              ]
            , readinessProbe = Some readinessProbe
            , resources
            , terminationMessagePolicy = Some "FallbackToLogsOnError"
            , securityContext
            }

in  Containers/preciseCodeIntelWorker/generate
