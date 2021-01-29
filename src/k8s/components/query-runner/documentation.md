# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [Containers](#containers)
    - [`query-runner`](#query-runner)
      - [image](#image)
      - [resources](#resources)
      - [additional environment variables](#additional-environment-variables)
      - [additional volume mounts](#additional-volume-mounts)
    - [`jaeger`](#jaeger)
      - [image](#image-1)
      - [resources](#resources-1)
  - [Additional SideCar Containers](#additional-sidecar-containers)

# Deployment

## Containers

### `query-runner`

#### image

**Customization snippet**:

```dhall
with query-runner.Deployment.Containers.query-runner.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/query-runner"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                     | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with query-runner.Deployment.Containers.query-runner.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with query-runner.Deployment.Containers.query-runner.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with query-runner.Deployment.Containers.query-runner.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                       | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with query-runner.Deployment.Containers.query-runner.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with query-runner.Deployment.Containers.query-runner.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with query-runner.Deployment.Containers.query-runner.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional environment variables

**Customization snipppet**:

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with query-runner.Deployment.Containers.query-runner.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
```

#### additional volume mounts

**Customization snipppet**:

```
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with query-runner.Deployment.Containers.query-runner.additionalVolumeMounts = [ VolumeMount :: {....} ]
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
with query-runner.Deployment.Containers.jaeger.image = <Image>
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
| CPU               | `with query-runner.Deployment.Containers.jaeger.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with query-runner.Deployment.Containers.jaeger.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with query-runner.Deployment.Containers.jaeger.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                 | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with query-runner.Deployment.Containers.jaeger.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with query-runner.Deployment.Containers.jaeger.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with query-runner.Deployment.Containers.jaeger.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with query-runner.Deployment.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```
