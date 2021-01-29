# Table of Contents

- [DaemonSet](#daemonset)
  - [Containers](#containers)
    - [cadvisor](#cadvisor)
      - [image](#image)
      - [resources](#resources)
    - [additional args](#additional-args)
    - [additional volume mounts](#additional-volume-mounts)

## DaemonSet

### Containers

#### cadvisor

##### image

**Customization snippet**:

```dhall
with cadvisor.DaemonSet.Containers.cadvisor.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/cadvisor"
      , registry = Some "index.docker.io"
      , digest = Some
          "abc123DEADBEEF"
      , tag = "some-tag"
      }
```

_The default values of `digest` and `tag` will vary depending on the release in question (e.x. `tag` will be `"3.21.1"` for the `3.21` Sourcegraph release, etc.)._

<!-- TODO: Should we even be documenting this, or should we just direct people to the global options? -->

##### resources

**Limits**:

| Resource type | Copy paste snippet                                                                  | Example values               |
| ------------- | ----------------------------------------------------------------------------------- | ---------------------------- |
| cpu           | `with cadvisor.DaemonSet.Containers.cadvisor.resources.limits.cpu = Some <Text>`    | `Some "100m"` / `None Text`  |
| memory        | `with cadvisor.DaemonSet.Containers.cadvisor.resources.limits.memory = Some <Text>` | `Some "512Mi"` / `None Text` |

**Requests**:

| Resource type | Copy paste snippet                                                                    | Example values               |
| ------------- | ------------------------------------------------------------------------------------- | ---------------------------- |
| cpu           | `with cadvisor.DaemonSet.Containers.cadvisor.resources.requests.cpu = Some <Text>`    | `Some "100m"` / `None Text`  |
| memory        | `with cadvisor.DaemonSet.Containers.cadvisor.resources.requests.memory = Some <Text>` | `Some "512Mi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional args

**Customization snippet**:

```dhall
with cadvisor.DaemonSet.Containers.cadvisor.additionalArgs = <List Text>
```

#### additional volume mounts

**Customization snipppet**:

```dhall
let Kubernetes/VolumeMount = ./src/deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

with cadvisor.DaemonSet.Containers.cadvisor.additionalVolumeMounts = [ VolumeMount :: {....} ]
```
