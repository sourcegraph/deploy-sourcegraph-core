-- dhall-to-yaml --explain --file src/k8s/pipeline.dhall
let Sourcegraph = ./package.dhall

let c
    : Sourcegraph.Configuration.Type
    = Sourcegraph.Configuration::{=}
      with jaeger.Deployment.Containers.jaeger.image
           =
        { name = "sourcegraph/jaeger"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "3.20.1"
        }
      with jaeger.Deployment.Containers.jaeger.additionalEnvVars
           =
        [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
      with jaeger.Deployment.Containers.jaeger.resources.limits.cpu
           = Some
          "100m"
      with jaeger.Deployment.Containers.jaeger.resources.limits.memory
           = Some
          "1Gi"
      with jaeger.Deployment.Containers.jaeger.resources.limits.ephemeralStorage
           = Some
          "500Gi"
      with jaeger.Deployment.Containers.jaeger.resources.requests.cpu = Some "A"
      with jaeger.Deployment.Containers.jaeger.resources.requests.memory
           = Some
          "B"
      with   jaeger
           . Deployment
           . Containers
           . jaeger
           . resources
           . requests
           . ephemeralStorage
           = Some
          "C"
      with jaeger.Deployment.Containers.jaeger.additionalVolumeMounts
           =
        [ Sourcegraph.Kubernetes.VolumeMount::{
          , name = "test volume"
          , mountPath = "/d/e/a/d/b/e/e/f"
          }
        ]
      with jaeger.Deployment.additionalSideCars
           =
        [ Sourcegraph.Kubernetes.Container::{
          , args = Some [ "bash", "-c", "echo 'hello world'" ]
          , env = Some
            [ Sourcegraph.Kubernetes.EnvVar::{
              , name = "FOO"
              , value = Some "BAR"
              }
            ]
          , image = Some "index.docker.io/your/image:tag@sha256:123456"
          , name = "sidecar"
          }
        ]

in  Sourcegraph.Generate c
