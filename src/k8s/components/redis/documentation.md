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
 Image::{
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

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with redis.Deployment.redis-cache.Containers.redis-cache.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
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

**Customization snipppet**:

```
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with redis.Deployment.redis-cache.Containers.redis-cache.additionalVolumeMounts = [ VolumeMount :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

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
 Image::{
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
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with redis.Deployment.redis-cache.Containers.redis-exporter.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
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
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with redis.Deployment.redis-cache.Containers.redis-cache.additionalVolumeMounts = [ VolumeMount :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

[] : (List Kubernetes/VolumeMount.Type)
```

### Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with redis.Deployment.redis-cache.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
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
 Image::{
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

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with redis.Deployment.redis-store.Containers.redis-store.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
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
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with redis.Deployment.redis-store.Containers.redis-store.additionalVolumeMounts = [ VolumeMount :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

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
 Image::{
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
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with redis.Deployment.redis-store.Containers.redis-exporter.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

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

```
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with redis.Deployment.redis-store.Containers.redis-store.additionalVolumeMounts = [ VolumeMount :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

[] : (List Kubernetes/VolumeMount.Type)
```

### Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with redis.Deployment.redis-store.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```
