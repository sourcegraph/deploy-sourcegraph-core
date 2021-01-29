# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [Containers](#containers)
    - [`github-proxy`](#github-proxy)
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

## Containers

### `github-proxy`

#### image

**Customization snipppet**:

```
with github-proxy.Deployment.Containers.github-proxy.image = <Image>
```

**Default value**:

```dhall
Image::{
      , name = "sourcegraph/github-proxy"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "3.20.1"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### environment variables

| Name           | Copy paste snippet                                                                                  | Default values |
| -------------- | --------------------------------------------------------------------------------------------------- | -------------- |
| `LOG_REQUESTS` | `with github-proxy.Deployment.Containers.github-proxy.environment.LOG_REQUESTS.value = Some <Text>` | `Some "false"` |

#### additional environment variables

**Customization snipppet**:

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with github-proxy.Deployment.Containers.github-proxy.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
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
| CPU               | `with github-proxy.Deployment.Containers.github-proxy.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with github-proxy.Deployment.Containers.github-proxy.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with github-proxy.Deployment.Containers.github-proxy.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                       | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with github-proxy.Deployment.Containers.github-proxy.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with github-proxy.Deployment.Containers.github-proxy.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with github-proxy.Deployment.Containers.github-proxy.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

#### additional volume mounts

**Customization snipppet**:

```
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with github-proxy.Deployment.Containers.github-proxy.additionalVolumeMounts = [ VolumeMount :: {....} ]
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
with github-proxy.Deployment.Containers.Jaeger.image = <Image>
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
| CPU               | `with github-proxy.Deployment.Containers.Jaeger.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with github-proxy.Deployment.Containers.Jaeger.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with github-proxy.Deployment.Containers.Jaeger.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                 | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with github-proxy.Deployment.Containers.Jaeger.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with github-proxy.Deployment.Containers.Jaeger.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with github-proxy.Deployment.Containers.Jaeger.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with github-proxy.Deployment.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```
