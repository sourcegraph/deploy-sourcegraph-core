-- dhall-to-yaml --explain --file src/k8s/pipeline.dhall
let Sourcegraph = ../../package.dhall

let c
    : Sourcegraph.Configuration.Type
    = Sourcegraph.Configuration::{=}
      with syntect-server.Deployment.Containers.syntect-server.image
           = Sourcegraph.Util.Image::{
        , name = "sourcegraph/syntect-server"
        , registry = Some "index.docker.io"
        , digest = Some "abc123DEADBEEF"
        , tag = "some-tag"
        }
      with syntect-server.Deployment.Containers.syntect-server.additionalEnvVars
           =
        [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
      with   syntect-server
           . Deployment
           . Containers
           . syntect-server
           . resources
           . limits
           . cpu
           = Some
          "100m"
      with   syntect-server
           . Deployment
           . Containers
           . syntect-server
           . resources
           . requests
           . memory
           = Some
          "1Gi"
      with   syntect-server
           . Deployment
           . Containers
           . syntect-server
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with   syntect-server
           . Deployment
           . Containers
           . syntect-server
           . resources
           . requests
           . cpu
           = Some
          "100m"
      with   syntect-server
           . Deployment
           . Containers
           . syntect-server
           . resources
           . requests
           . memory
           = Some
          "1Gi"
      with   syntect-server
           . Deployment
           . Containers
           . syntect-server
           . resources
           . requests
           . ephemeralStorage
           = Some
          "500Gi"
      with syntect-server.Deployment.additionalSideCars
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
      with syntect-server.Deployment.additionalVolumes
           =
        [ Sourcegraph.Kubernetes.Volume::{
          , name = "your-test-volume"
          , nfs = Some Sourcegraph.Kubernetes.NFSVolumeSource::{
            , path = "TEST_PATH"
            , server = "my.testing.server.io"
            }
          }
        ]

in  Sourcegraph.Generate c
