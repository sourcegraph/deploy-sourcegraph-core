# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [replicas](#replicas)
  - [volumes](#volumes)
  - [Containers](#containers)
    - [`symbols`](#symbols)
      - [image](#image)
      - [environment variables](#environment-variables)
      - [additional environment variables](#additional-environment-variables)
      - [resources](#resources)
      - [additional volume mounts](#additional-volume-mounts)
    - [`jaeger`](#jaeger)
      - [image](#image-1)
      - [resources](#resources-1)
  - [Additional SideCar Containers](#additional-sidecar-containers)

# Deployment

## replicas

**Customization snippet**:

```dhall
with Symbols.Deployment.replicas = <Natural>
```

**Default value**:

```dhall
1
```

## volumes

| Name        | Copy paste snippet                                     | Default values                                                                                   |
| ----------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `cache_ssd` | `with symbols.Deployment.volumes.cache-ssd = <Volume>` | `Kubernetes/volume::{name = "cache-ssd", emptyDir = Some Kubernetes/EmptyDirVolumeSource::{=} }` |

<!-- TODO: We need to figure out how to document this better since [the volume type](../../../deps/k8s/types/io.k8s.api.core.v1.Volume.dhall) has a ton of fields... -->

<!-- TODO: Make sure to revisit putting the name after every resource type for consistency (e.g. `symbols.Deployment.symbols...` instead of just `symbols.Deployment`) -->

## Containers

### `symbols`

#### image

**Customization snippet**:

```dhall
with Symbols.Deployment.Containers.Symbols.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/symbols"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### environment variables

| Name                    | Copy paste snippet                                                                                 | Default values                                                                                                    |
| ----------------------- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `CACHE_DIR`             | `with symbols.Deployment.Containers.symbols.environment.CACHE_DIR.value = Some <Text>`             | `Some "/mnt/cache\$(POD_NAME)"`                                                                                   |
| `POD_NAME`              | `with symbols.Deployment.Containers.symbols.environment.POD_NAME.valueFrom = Some <EnvVarSource>`  | `Some Kubernetes/EnvVarSource::{, fieldRef = Some Kubernetes/ObjectFieldSelector::{fieldPath = "metadata.name"}}` |
| `SYMBOLS_CACHE_SIZE_MB` | `with symbols.Deployment.Containers.symbols.environment.SYMBOLS_CACHE_SIZE_MB.value = Some <Text>` | `Some "100000"`                                                                                                   |

**Notes**:

- `<EnvVarSource>`: See [the Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#envvarsource-v1-core) for more information about this type.

<!--
- `CACHE_DIR`

  - Customization snippet:

    ```dhall
    with symbols.Deployment.Containers.symbols.environment.CACHE_DIR.value = Some <Text>
    ```

  - Default value:

    ```dhall
    Some "/mnt/cache\$(POD_NAME)"
    ```

- `POD_NAME`

  - Customization snippet:

    ```dhall
    with symbols.Deployment.Containers.symbols.environment.POD_NAME.valueFrom = Some <FieldRef>
    ```

  - Default value:

    ```dhall
    Some Kubernetes/EnvVarSource::{
    , fieldRef = Some Kubernetes/ObjectFieldSelector::{
      , fieldPath = "metadata.name"
      }
    }
    ```

- `SYMBOLS_CACHE_SIZE_MB`

  - Customization snippet:

    ```dhall
    with symbols.Deployment.Containers.symbols.environment.SYMBOLS_CACHE_SIZE_MB.value
    ```

  - Default value:

        ```dhall
        Some "100000"
        ```

    -->

#### additional environment variables

**Customization snipppet**:

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with symbols.Deployment.Containers.symbols.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
```

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                           | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with symbols.Deployment.Containers.symbols.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with symbols.Deployment.Containers.symbols.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with symbols.Deployment.Containers.symbols.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                             | Example values               |
| ----------------- | ---------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with symbols.Deployment.Containers.symbols.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with symbols.Deployment.Containers.symbols.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with symbols.Deployment.Containers.symbols.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional volume mounts

**Customization snipppet**:

```
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with symbols.Deployment.Containers.symbols.additionalVolumeMounts = [ VolumeMount :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

[] : (List Kubernetes/VolumeMount.Type)
```

### `jaeger`

#### image

**Customization snippet**:

```dhall
with Symbols.Deployment.Containers.jaeger.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/jaeger-agent"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                          | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with symbols.Deployment.Containers.jaeger.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with symbols.Deployment.Containers.jaeger.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with symbols.Deployment.Containers.jaeger.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                            | Example values               |
| ----------------- | --------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with symbols.Deployment.Containers.jaeger.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with symbols.Deployment.Containers.jaeger.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with symbols.Deployment.Containers.jaeger.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with symbols.Deployment.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```
