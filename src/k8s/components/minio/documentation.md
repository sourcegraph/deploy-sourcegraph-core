# Table of Contents

- [Table of Contents](#table-of-contents)
- [Deployment](#deployment)
  - [Containers](#containers)
    - [`minio`](#minio)
      - [image](#image)
      - [resources](#resources)
- [PersistentVolumeClaim](#persistentvolumeclaim)
  - [name](#name)

# Deployment

## Containers

### `minio`

#### image

**Customization snippet**:

```
with minio.Deployment.Containers.minio.image = <Image>
```

**Default value**:

```dhall
Image::{
      , name = "sourcegraph/minio"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "3.20.1"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

#### resources

**Limits**:

| Resource type     | Copy paste snippet                                                                       | Example values               |
| ----------------- | ---------------------------------------------------------------------------------------- | ---------------------------- |
| CPU               | `with minio.Deployment.Containers.minio.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with minio.Deployment.Containers.minio.resources.limits.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with minio.Deployment.Containers.minio.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type     | Copy paste snippet                                                                         | Example values               |
| ----------------- | ------------------------------------------------------------------------------------------ | ---------------------------- |
| CPU               | `with minio.Deployment.Containers.minio.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| Memory            | `with minio.Deployment.Containers.minio.resources.requests.memory = Some <Text>`           | `Some "1Gi"` / `None Text`   |
| Ephemeral storage | `with minio.Deployment.Containers.minio.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

# PersistentVolumeClaim

## name

**Customization snippet**:

```
with minio.PersistentVolumeClaim.name = <Text>
```

**Default value**:

```
"minio"
```
