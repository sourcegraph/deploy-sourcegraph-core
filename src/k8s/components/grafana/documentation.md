# Table of Contents

- [Table of Contents](#table-of-contents)
  - [Service](#service)
  - [StatefulSet](#statefulset)
    - [Containers](#containers)
      - [Grafana](#grafana)
        - [image](#image)
        - [resources](#resources)
      - [additional environment variables](#additional-environment-variables)
      - [additional volume mounts](#additional-volume-mounts)
    - [dataVolumeSize](#datavolumesize)
  - [ConfigMap](#configmap)
    - [datasources](#datasources)
  - [Additional SideCar Containers](#additional-sidecar-containers)
  - [PersistentVolume](#persistentvolume)
    - [spec](#spec)

## Service

No special options available.

## StatefulSet

### Containers

#### Grafana

##### image

**Customization snippet**:

```dhall
with Grafana.StatefulSet.Containers.Grafana.image = <Image>
```

**Default value**:

```dhall
 Image::{
      , name = "sourcegraph/grafana"
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

| Resource type    | Copy paste snippet                                                                            | Example values               |
| ---------------- | --------------------------------------------------------------------------------------------- | ---------------------------- |
| cpu              | `with Grafana.StatefulSet.Containers.Grafana.resources.limits.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| memory           | `with Grafana.StatefulSet.Containers.Grafana.resources.limits.memory = Some <Text>`           | `Some "512Mi"` / `None Text` |
| ephemeralStorage | `with Grafana.StatefulSet.Containers.Grafana.resources.limits.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Requests**:

| Resource type    | Copy paste snippet                                                                              | Example values               |
| ---------------- | ----------------------------------------------------------------------------------------------- | ---------------------------- |
| cpu              | `with Grafana.StatefulSet.Containers.Grafana.resources.requests.cpu = Some <Text>`              | `Some "100m"` / `None Text`  |
| memory           | `with Grafana.StatefulSet.Containers.Grafana.resources.requests.memory = Some <Text>`           | `Some "512Mi"` / `None Text` |
| ephemeralStorage | `with Grafana.StatefulSet.Containers.Grafana.resources.requests.ephemeralStorage = Some <Text>` | `Some "500Gi"` / `None Text` |

**Notes**:

- See [the Kubernetes resource units documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes) for more information on the types of values that you are allowed to specify for resources.

#### additional environment variables

**Customization snipppet**:

```
let fenv = ./src/k8s/util/functions/environment-to-k8s.dhall

with grafana.StatefulSet.Containers.grafana.additionalEnvVars = [ fenv { name = "fooKey", value = "fooValue" } ]
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

with grafana.StatefulSet.Containers.grafana.additionalVolumeMounts = [ VolumeMount :: {....} ]
```

### dataVolumeSize

PersistentVolumeClaim volumeClaimTemplate storage size for the Grafana StatefulSet. Also see [PersistentVolume](#persistentvolume).

**Customization snippet**:

```dhall
with Grafana.StatefulSet.dataVolumeSize = <Text>
```

**Default value**:

```dhall
"2Gi"
```

## ConfigMap

### datasources

Datasources for Grafana to connect to.

**Customization snippet**:

```dhall
with Grafana.ConfigMap.datasources = <Text>
```

**Default value**:

```dhall
''
apiVersion: 1

datasources:
- name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:30090
    isDefault: true
    editable: false
- name: Jaeger
    type: Jaeger
    access: proxy
    url: http://jaeger-query:16686/-/debug/jaeger
    editable: false
''
```

## Additional SideCar Containers

**Customization snipppet**:

```
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

with grafana.StatefulSet.additionalSideCars = [ Container :: {....} ]
```

**Default value**:

```dhall
let Kubernetes/Container = ./src/deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

[] : (List Kubernetes/Container.Type)
```

## PersistentVolume

### spec

Raw Kubernetes persistent volume specification.

**Customization snippet**:

```dhall
with Grafana.PersistentVolume.spec = Some <Kubernetes/PersistentVolumeSpec.Type>
```
