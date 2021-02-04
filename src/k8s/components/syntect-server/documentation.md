# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [Containers](#containers)
    - [`syntect-server`](#syntect-server)
      - [image](#image)
      - [additional environment variables](#additional-environment-variables)
      - [resources](#resources)
      - [additional volume mounts](#additional-volume-mounts)
  - [Additional SideCar containers](#additional-sidecar-containers)
  - [Additional volumes](#additional-volumes)

# Deployment

## Containers

### `syntect-server`

#### image

**Customization snippet**:

```dhall
with syntect-server.Deployment.Containers.syntect-server.image = <Image>
```

**Default value**:

```dhall
 Sourcegraph.Util.Image::{
      , name = "sourcegraph/syntect-server"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
}
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### additional environment variables

**Customization snipppet**:

```

with syntect-server.Deployment.Containers.syntect-server.additionalEnvVars = [
  Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" }
]
```

**Default value**:

```dhall
[] : (List Sourcegraph.Kubernetes.EnvVar.Type)
```

**Notes**:

- `<EnvVarSource>`: See [the Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#envvarsource-v1-core) for more information about this type.

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                         | Example values               |
| ----------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with syntect-server.Deployment.Containers.syntect-server.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with syntect-server.Deployment.Containers.syntect-server.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with syntect-server.Deployment.Containers.syntect-server.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                           | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with syntect-server.Deployment.Containers.syntect-server.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with syntect-server.Deployment.Containers.syntect-server.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with syntect-server.Deployment.Containers.syntect-server.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional volume mounts

**Customization snipppet**:

```
with syntect-server.Deployment.Containers.syntect-server.additionalVolumeMounts = [
  Sourcegraph.Kubernetes.VolumeMount::{....}
]
```

**Default value**:

```dhall

[] : (List Sourcegraph.Kubernetes.VolumeMount.Type)
```

## Additional SideCar containers

**Customization snipppet**:

```dhall
with syntect-server.Deployment.additionalSideCars = [
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
]
```

**Default value**:

```dhall
[] : (List Sourcegraph.Kubernetes.Container.Type)
```

## Additional volumes

**Customization snipppet**:

```dhall

with syntect-server.Deployment.additionalVolumes = [ Sourcegraph.Kubernetes.Volume::{....} ]
```

**Default value**:

```dhall

[] : (List Sourcegraph.Kubernetes.Volume.Type)
```

**Example value**:

```dhall
[
  Sourcegraph.Kubernetes.Volume::{
    , name = "your-test-volume"
    , nfs = Some Sourcegraph.Kubernetes.NFSVolumeSource::{
      , path = "TEST_PATH"
      , server = "my.testing.server.io"
      }
  }
]
```
