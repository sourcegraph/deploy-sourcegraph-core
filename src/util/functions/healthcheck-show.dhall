let Optional/map =
      https://prelude.dhall-lang.org/v18.0.0/Optional/map.dhall sha256:501534192d988218d43261c299cc1d1e0b13d25df388937add784778ab0054fa

let Kubernetes/ExecAction =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ExecAction.dhall

let Kubernetes/Probe = ../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/HTTPGetAction =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall

let Kubernetes/TCPSocketAction =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.TCPSocketAction.dhall

let Kubernetes/IntOrString =
      ../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let types = ../types.dhall

let HealthCheck = types.HealthCheck

let HealthCheck/Scheme = types.HealthCheck/Scheme

let DockerCompose/HealthCheck = ../../docker-compose/schemas/healthcheck.dhall

let DockerCompose/HealthCheck-Test =
      ../../docker-compose/schemas/healthcheck-test.dhall

let scheme/showK8s
    : ∀(s : HealthCheck/Scheme) → Text
    = λ(s : HealthCheck/Scheme) → merge { HTTP = "HTTP", TCP = "TCP" } s

let commandToK8s
    : ∀(c : types.Command) → Kubernetes/ExecAction.Type
    = λ(c : types.Command) →
        merge
          { Exec =
              λ(e : List Text) → Kubernetes/ExecAction::{ command = Some e }
          , Shell =
              λ(e : List Text) →
                Kubernetes/ExecAction::{
                , command = Some ([ "/bin/sh", "-c" ] # e)
                }
          , Raw = λ(e : Text) → Kubernetes/ExecAction::{ command = Some [ e ] }
          }
          c

let networkHealthToK8s
    : ∀(h : types.NetworkHealth) → Kubernetes/Probe.Type
    = λ(h : types.NetworkHealth) →
        merge
          { HTTP = Kubernetes/Probe::{
            , initialDelaySeconds = h.initialDelaySeconds
            , periodSeconds = h.intervalSeconds
            , timeoutSeconds = h.timeoutSeconds
            , failureThreshold = h.retries
            , httpGet = Some Kubernetes/HTTPGetAction::{
              , path = Some h.endpoint
              , port = Kubernetes/IntOrString.Int h.port
              , scheme = Some (scheme/showK8s h.scheme)
              }
            }
          , TCP = Kubernetes/Probe::{
            , initialDelaySeconds = h.initialDelaySeconds
            , periodSeconds = h.intervalSeconds
            , timeoutSeconds = h.timeoutSeconds
            , failureThreshold = h.retries
            , tcpSocket = Some Kubernetes/TCPSocketAction::{
              , port = Kubernetes/IntOrString.Int h.port
              }
            }
          }
          h.scheme

let toK8s
    : ∀(hc : HealthCheck) → Kubernetes/Probe.Type
    = λ(hc : HealthCheck) →
        merge
          { Exec =
              λ(h : types.ExecHealth) →
                Kubernetes/Probe::{
                , initialDelaySeconds = h.initialDelaySeconds
                , periodSeconds = h.intervalSeconds
                , timeoutSeconds = h.timeoutSeconds
                , failureThreshold = h.retries
                , exec = Some (commandToK8s h.command)
                }
          , Network = λ(h : types.NetworkHealth) → networkHealthToK8s h
          }
          hc

let commandToDockerCompose
    : ∀(c : types.Command) → DockerCompose/HealthCheck-Test
    = λ(c : types.Command) →
        merge
          { Exec =
              λ(e : List Text) →
                DockerCompose/HealthCheck-Test.ArgList ([ "CMD" ] # e)
          , Shell =
              λ(e : List Text) →
                DockerCompose/HealthCheck-Test.ArgList ([ "CMD-SHELL" ] # e)
          , Raw = λ(e : Text) → DockerCompose/HealthCheck-Test.Raw e
          }
          c

let scheme/showDockerCompose
    : ∀(s : HealthCheck/Scheme) → Text
    = λ(s : HealthCheck/Scheme) → merge { HTTP = "http", TCP = "tcp" } s

let toDockerComposeNetwork
    : ∀(hc : types.NetworkHealth) → DockerCompose/HealthCheck.Type
    = λ(hc : types.NetworkHealth) →
        let toSeconds
            : Optional Natural → Optional Text
            = λ(seconds : Optional Natural) →
                Optional/map
                  Natural
                  Text
                  (λ(n : Natural) → "${Natural/show n}s")
                  seconds

        let url =
              "${scheme/showDockerCompose
                   hc.scheme}://127.0.0.1:${Natural/show hc.port}${hc.endpoint}"

        let test =
              DockerCompose/HealthCheck-Test.Raw
                "wget -q '${url}' -O /dev/null || exit 1"

        in  DockerCompose/HealthCheck::{
            , interval = toSeconds hc.intervalSeconds
            , retries = hc.retries
            , start_period = toSeconds hc.initialDelaySeconds
            , test
            , timeout = toSeconds hc.timeoutSeconds
            }

let toDockerComposeExec
    : ∀(hc : types.ExecHealth) → DockerCompose/HealthCheck.Type
    = λ(hc : types.ExecHealth) →
        let toSeconds
            : Optional Natural → Optional Text
            = λ(seconds : Optional Natural) →
                Optional/map
                  Natural
                  Text
                  (λ(n : Natural) → "${Natural/show n}s")
                  seconds

        let test = commandToDockerCompose hc.command

        in  DockerCompose/HealthCheck::{
            , interval = toSeconds hc.intervalSeconds
            , retries = hc.retries
            , start_period = toSeconds hc.initialDelaySeconds
            , test
            , timeout = toSeconds hc.timeoutSeconds
            }

let toDockerCompose
    : ∀(hc : HealthCheck) → DockerCompose/HealthCheck.Type
    = λ(hc : HealthCheck) →
        merge
          { Network = toDockerComposeNetwork, Exec = toDockerComposeExec }
          hc

in  { HealthCheck/tok8s = toK8s, HealthCheck/toDockerCompose = toDockerCompose }
