# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [Containers](#containers)
    - [`jaeger`](#jaeger)
      - [image](#image)
      - [additional environment variables](#additional-environment-variables)
      - [resources](#resources)
      - [additional volumes](#additional-volumes)
  - [Additional SideCar Containers](#additional-sidecar-containers)
  - [Additional volumes](#additional-volumes-1)

# Deployment

## Containers

### `jaeger`

#### image

**Customization snipppet**:

```dhall
with jaeger.Deployment.Containers.jaeger.image = <Image>
```

**Default value**:

```dhall
Image::{
      , name = "sourcegraph/jaeger"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "3.20.1"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### additional environment variables

**Customization snipppet**:

```

with jaeger.Deployment.Containers.jaeger.additionalEnvVars = [ Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
[] : (List Sourcegraph.Kubernetes/EnvVar.Type)
```

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                         | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with jaeger.Deployment.Containers.jaeger.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with jaeger.Deployment.Containers.jaeger.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with jaeger.Deployment.Containers.jaeger.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                           | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with jaeger.Deployment.Containers.jaeger.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with jaeger.Deployment.Containers.jaeger.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with jaeger.Deployment.Containers.jaeger.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

#### additional volumes

**Customization snipppet**:

```dhall

with jaeger.Deployment.additionalVolumes = [ Sourcegraph.Kubernetes.Volume :: {....} ]
```

**Default value**:

```dhall

[] : (List Sourcegraph.Kubernetes.Volume.Type)
```

**Example value**

```dhall
Sourcegraph.Kubernetes.Volume::{
          , name = "your-test-volume"
          , nfs = Some Sourcegraph.Kubernetes.NFSVolumeSource::{
            , path = "TEST_PATH"
            , server = "my.testing.server.io"
            }
}
```

## Additional SideCar Containers

**Customization snippet**:

```dhall

with jaeger.Deployment.additionalSideCars = [ Sourcegraph.Kubernetes.Container :: {....} ]
```

**Default value**:

```dhall

[] : (List Sourcegraph.Kubernetes.Container.Type)
```

**Example value**:

```dhall

Sourcegraph.Kubernetes.Container::{
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
```

## Additional volumes

**Customization snipppet**:

```dhall

with jaeger.Deployment.additionalVolumes = [ Sourcegraph.Kubernetes.Volume :: {....} ]
```

**Default value**:

```dhall

[] : (List Sourcegraph.Kubernetes.Volume.Type)
```

**Example value**

```dhall
Sourcegraph.Kubernetes.Volume::{
          , name = "your-test-volume"
          , nfs = Some Sourcegraph.Kubernetes.NFSVolumeSource::{
            , path = "TEST_PATH"
            , server = "my.testing.server.io"
            }
}
```
