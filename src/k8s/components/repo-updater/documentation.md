# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [volumes](#volumes)
  - [Containers](#containers)
    - [`repo-updater`](#repo-updater)
      - [image](#image)
      - [additional environment variables](#additional-environment-variables)
      - [resources](#resources)
      - [additional volume mounts](#additional-volume-mounts)
    - [`jaeger`](#jaeger)
      - [image](#image-1)
      - [resources](#resources-1)
  - [Additional SideCar Containers](#additional-sidecar-containers)

# Deployment

**Customization snippet**:

```dhall
with RepoUpdater.Deployment.Containers = <Natural>
```

**Default value**:

```dhall
1
```

## volumes

| Name        | Copy paste snippet                                          | Default values                                                                                   |
| ----------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `cache_ssd` | `with repo-updater.Deployment.volumes.cache-ssd = <Volume>` | `Kubernetes/volume::{name = "cache-ssd", emptyDir = Some Kubernetes/EmptyDirVolumeSource::{=} }` |

<!-- TODO: We need to figure out how to document this better since [the volume type](../../../deps/k8s/types/io.k8s.api.core.v1.Volume.dhall) has a ton of fields... -->

<!-- TODO: Make sure to revisit putting the name after every resource type for consistency (e.g. `repo-updater.Deployment.symbols...` instead of just `repo-updater.Deployment`) -->

## Containers

### `repo-updater`

#### image

**Customization snippet**:

```dhall
with RepoUpdater.Deployment.Containers.repo-updater.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/repo-updater"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

#### additional environment variables

**Customization snipppet**:

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with repo-updater.Deployment.Containers.repo-updater.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
```

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                     | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with repo-updater.Deployment.Containers.repo-updater.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with repo-updater.Deployment.Containers.repo-updater.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with repo-updater.Deployment.Containers.repo-updater.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                       | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with repo-updater.Deployment.Containers.repo-updater.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with repo-updater.Deployment.Containers.repo-updater.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with repo-updater.Deployment.Containers.repo-updater.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional volume mounts

**Customization snipppet**:

```
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with repo-updater.Deployment.Containers.repo-updater.additionalVolumeMounts = [ VolumeMount :: {....} ]
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
with RepoUpdater.Deployment.Containers.Jaeger.image = <Image>
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

| Resource type     | Copy paste snippet                                                                               | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with repo-updater.Deployment.Containers.jaeger.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with repo-updater.Deployment.Containers.jaeger.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with repo-updater.Deployment.Containers.jaeger.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                 | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with repo-updater.Deployment.Containers.jaeger.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with repo-updater.Deployment.Containers.jaeger.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with repo-updater.Deployment.Containers.jaeger.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with repo-updater.Deployment.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```
