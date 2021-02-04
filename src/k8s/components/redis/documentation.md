# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [redis-cache](#redis-cache)
    - [Containers](#containers)
      - [`redis-cache`](#redis-cache-1)
        - [image](#image)
        - [additional environment variables](#additional-environment-variables)
        - [resources](#resources)
        - [additional volume mounts](#additional-volume-mounts)
      - [`redis-exporter`](#redis-exporter)
        - [image](#image-1)
        - [additional environment variables](#additional-environment-variables-1)
        - [resources](#resources-1)
        - [additional volume mounts](#additional-volume-mounts-1)
    - [Additional SideCar Containers](#additional-sidecar-containers)
    - [Additional volumes](#additional-volumes)
  - [redis-store](#redis-store)
    - [Containers](#containers-1)
      - [`redis-store`](#redis-store-1)
        - [image](#image-2)
        - [additional environment variables](#additional-environment-variables-2)
        - [resources](#resources-2)
        - [additional volume mounts](#additional-volume-mounts-2)
      - [`redis-exporter`](#redis-exporter-1)
        - [image](#image-3)
        - [additional environment variables](#additional-environment-variables-3)
        - [resources](#resources-3)
        - [additional volume mounts](#additional-volume-mounts-3)
    - [Additional SideCar Containers](#additional-sidecar-containers-1)
    - [Additional volumes](#additional-volumes-1)

# Deployment

## redis-cache

### Containers

#### `redis-cache`

##### image

**Customization snippet**:

```dhall
with redis.Deployment.redis-cache.Containers.redis-cache.image = <Image>
```

**Default value**:

```dhall
 Sourcegraph.Util.Image::{
      , name = "sourcegraph/redis-cache"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
}
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

##### additional environment variables

**Customization snipppet**:

```dhall
with redis.Deployment.redis-cache.Containers.redis-cache.additionalEnvVars = [
  Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" }
]
```

**Default value**:

```dhall
[] : (List Sourcegraph.Kubernetes.EnvVar.Type)
```

##### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                         | Example values               |
| ----------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with redis.Deployment.redis-cache.Containers.redis-cache.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-cache.Containers.redis-cache.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-cache.Containers.redis-cache.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                           | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with redis.Deployment.redis-cache.Containers.redis-cache.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-cache.Containers.redis-cache.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-cache.Containers.redis-cache.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

##### additional volume mounts

**Customization snippet**:

```dhall
with redis.Deployment.redis-cache.Containers.redis-cache.additionalVolumeMounts = [
  Sourcegraph.Kubernetes.VolumeMount::{
    , name = "fake-volume"
    , mountPath = "/your/name/should/be/in/lights"
  }
]
```

**Default value**:

```dhall
[] : (List Kubernetes/VolumeMount.Type)
```

#### `redis-exporter`

##### image

**Customization snippet**:

```dhall
with redis.Deployment.redis-cache.Containers.redis-exporter.image = <Image>
```

**Default value**:

```dhall
Sourcegraph.Util.Image::{
  , name = "sourcegraph/redis_exporter"
  , registry = Some "index.docker.io"
  , digest = Some
      "abc123DEADBEEF"
  , tag = "some-tag"
}
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

##### additional environment variables

**Customization snippet**:

```dhall
with redis.Deployment.redis-cache.Containers.redis-exporter.additionalEnvVars = [
  Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" }
]
```

**Default value**:

```dhall
[] : (List Sourcegraph.Kubernetes.EnvVar.Type)
```

##### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                            | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with redis.Deployment.redis-cache.Containers.redis-exporter.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-cache.Containers.redis-exporter.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-cache.Containers.redis-exporter.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                              | Example values               |
| ----------------- | --------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with redis.Deployment.redis-cache.Containers.redis-exporter.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-cache.Containers.redis-exporter.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-cache.Containers.redis-exporter.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

##### additional volume mounts

**Customization snipppet**:

```
with redis.Deployment.redis-cache.Containers.redis-cache.additionalVolumeMounts = [
  Sourcegraph.Kubernetes.VolumeMount::{
    , name = "fake-volume"
    , mountPath = "/your/name/should/be/in/lights"
  }
]
```

**Default value**:

```dhall
[] : (List Kubernetes/VolumeMount.Type)
```

### Additional SideCar Containers

**Customization snipppet**:

```dhall
with redis.Deployment.redis-cache.additionalSideCars = [
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

### Additional volumes

**Customization snipppet**:

```dhall
with redis.Deployment.redis-cache.additionalVolumes = [
  Sourcegraph.Kubernetes.Volume::{
    ...
  }
]
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

## redis-store

### Containers

#### `redis-store`

##### image

**Customization snippet**:

```dhall
with redis.Deployment.redis-store.Containers.redis-store.image = <Image>
```

**Default value**:

```dhall
 Sourcegraph.Util.Image::{
  , name = "sourcegraph/redis-store"
  , registry = Some "index.docker.io"
  , digest = Some
      "abc123DEADBEEF"
  , tag = "some-tag"
}
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

##### additional environment variables

**Customization snipppet**:

```dhall
with redis.Deployment.redis-store.Containers.redis-store.additionalEnvVars = [
 Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" }
]
```

**Default value**:

```dhall
[] : (List Sourcegraph.Kubernetes.EnvVar.Type)
```

##### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                         | Example values               |
| ----------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with redis.Deployment.redis-store.Containers.redis-store.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-store.Containers.redis-store.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-store.Containers.redis-store.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                           | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with redis.Deployment.redis-store.Containers.redis-store.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-store.Containers.redis-store.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-store.Containers.redis-store.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

##### additional volume mounts

**Customization snipppet**:

```
with redis.Deployment.redis-store.Containers.redis-store.additionalVolumeMounts = [
  Sourcegraph.Kubernetes.VolumeMount::{
  ...
  }
]
```

**Default value**:

```dhall
[] : (List Kubernetes/VolumeMount.Type)
```

#### `redis-exporter`

##### image

**Customization snippet**:

```dhall
with redis.Deployment.redis-store.Containers.redis-exporter.image = <Image>
```

**Default value**:

```dhall
Sourcegraph.Util.Image::{
  , name = "sourcegraph/redis_exporter"
  , registry = Some "index.docker.io"
  , digest = Some
      "abc123DEADBEEF"
  , tag = "some-tag"
}
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

##### additional environment variables

**Customization snipppet**:

```
with redis.Deployment.redis-store.Containers.redis-exporter.additionalEnvVars = [
  Sourcegraph.Util.EnvToK8s { name = "fooKey", value = "fooValue" }
]
```

**Default value**:

```dhall
[] : (List Kubernetes/EnvVar.Type)
```

##### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                            | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with redis.Deployment.redis-store.Containers.redis-exporter.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-store.Containers.redis-exporter.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-store.Containers.redis-exporter.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                              | Example values               |
| ----------------- | --------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with redis.Deployment.redis-store.Containers.redis-exporter.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with redis.Deployment.redis-store.Containers.redis-exporter.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with redis.Deployment.redis-store.Containers.redis-exporter.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

##### additional volume mounts

**Customization snipppet**:

```dhall
with redis.Deployment.redis-store.Containers.redis-store.additionalVolumeMounts = [
  Sourcegraph.Kubernetes.VolumeMount::{
    , name = "fake-volume"
    , mountPath = "/your/name/should/be/in/lights"
  }
]
```

**Default value**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

[] : (List Kubernetes/VolumeMount.Type)
```

### Additional SideCar Containers

**Customization snipppet**:

```dhall
with redis.Deployment.redis-store.additionalSideCars = [
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

### Additional volumes

**Customization snipppet**:

```dhall
with redis.Deployment.redis-store.additionalVolumes = [
  Sourcegraph.Kubernetes.Volume::{
    ...
  }
]
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
