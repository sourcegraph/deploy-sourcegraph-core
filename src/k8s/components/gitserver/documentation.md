# Table of Contents

- [Table of Contents](#table-of-contents)
- [StatefulSet](#statefulset)
  - [replicas](#replicas)
  - [reposVolumeSize](#reposvolumesize)
  - [Containers](#containers)
    - [`gitserver`](#gitserver)
      - [image](#image)
      - [resources](#resources)
      - [additional environment variables](#additional-environment-variables)
      - [additional volume mounts](#additional-volume-mounts)
    - [`jaeger`](#jaeger)
      - [image](#image-1)
      - [resources](#resources-1)
  - [Additional SideCar Containers](#additional-sidecar-containers)
- [PersistentVolumeGenerator](#persistentvolumegenerator)

# StatefulSet

## replicas

**Customization snippet**:

```dhall
with gitserver.StatefulSet.replicas = <Natural>
```

**Default value**:

```dhall
1
```

## reposVolumeSize

```dhall
with gitserver.StatefulSet.replicas = <Text>
```

**Default value**:

```dhall
"200Gi"
```

## Containers

### `gitserver`

#### image

**Customization snippet**:

```dhall
with gitserver.StatefulSet.Containers.gitserver.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/gitserver"
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

| Resource type     | Copy paste snippet                                                                               | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with gitserver.Deployment.Containers.gitserver.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with gitserver.Deployment.Containers.gitserver.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with gitserver.Deployment.Containers.gitserver.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                                 | Example values               |
| ----------------- | -------------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with gitserver.Deployment.Containers.gitserver.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with gitserver.Deployment.Containers.gitserver.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with gitserver.Deployment.Containers.gitserver.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional environment variables

**Customization snipppet**:

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with gitserver.StatefulSet.Containers.gitserver.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
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

with gitserver.StatefulSet.Containers.gitserver.additionalVolumeMounts = [ VolumeMount :: {....} ]
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
with gitserver.StatefulSet.Containers.Jaeger.image = <Image>
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

| Resource type     | Copy paste snippet                                                                             | Example values               |
| ----------------- | ---------------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with gitserver.StatefulSet.Containers.Jaeger.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with gitserver.StatefulSet.Containers.Jaeger.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with gitserver.StatefulSet.Containers.Jaeger.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                               | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with gitserver.StatefulSet.Containers.Jaeger.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with gitserver.StatefulSet.Containers.Jaeger.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with gitserver.StatefulSet.Containers.Jaeger.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with gitserver.StatefulSet.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```

# PersistentVolumeGenerator

**Customization snippet**:

```dhall
let Kubernetes/PersistentVolumeSpec =
      ../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeSpec.dhall

let Kubernetes/GCEPersistentDiskVolumeSource =
      ../deps/k8s/schemas/io.k8s.api.core.v1.GCEPersistentDiskVolumeSource.dhall

let pvGenerator
    : ∀(replicaIndex : Natural) → Kubernetes/PersistentVolumeSpec.Type
    = λ(replicaIndex : Natural) →
        let replicaIndexStr = Natural/show replicaIndex

        let pv =
              Kubernetes/PersistentVolumeSpec::{
              , accessModes = Some [ "ReadWriteOnce" ]
              , capacity = Some (toMap { storage = "4Ti" })
              , gcePersistentDisk = Some Kubernetes/GCEPersistentDiskVolumeSource::{
                , pdName = "repos-gitserver-${replicaIndexStr}---cloud"
                , fsType = Some "ext4"
                }
              , storageClassName = Some "devnullish"
              }

        in  pv

with gitserver.PersistentVolumeGenerator = pvGenerator
```
