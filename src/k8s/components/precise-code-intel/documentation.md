# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [Containers](#containers)
    - [`precise-code-intel`](#precise-code-intel)
      - [image](#image)
      - [additional environment variables](#additional-environment-variables)
      - [resources](#resources)
  - [Additional SideCar Containers](#additional-sidecar-containers)

# Deployment

**Customization snippet**:

```dhall
with precise-code-intel.Deployment.Containers = <Natural>
```

**Default value**:

```dhall
1
```

## Containers

### `precise-code-intel`

#### image

**Customization snippet**:

```dhall
with precise-code-intel.Deployment.Containers.precise-code-intel.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/precise-code-intel"
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

with precise-code-intel.Deployment.Containers.precise-code-intel.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
```

**Default value**:

```dhall
let Kubernetes/EnvVar = ./src/deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

[] : (List Kubernetes/EnvVar.Type)
```

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                                                 | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with precise-code-intel.Deployment.Containers.precise-code-intel.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with precise-code-intel.Deployment.Containers.precise-code-intel.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with precise-code-intel.Deployment.Containers.precise-code-intel.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                                   | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with precise-code-intel.Deployment.Containers.precise-code-intel.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with precise-code-intel.Deployment.Containers.precise-code-intel.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with precise-code-intel.Deployment.Containers.precise-code-intel.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with precise-code-intel.Deployment.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```
