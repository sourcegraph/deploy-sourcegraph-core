# Table of contents

- [Table of contents](#table-of-contents)
- [Global configuration options](#global-configuration-options)
  - [Image manipulations](#image-manipulations)
  - [Namespace](#namespace)
  - [Storage class name](#storage-class-name)
  - [Non-root users/groups](#non-root-usersgroups)

# Global configuration options

## Image manipulations

Manipulate image definitions across all Sourcegraph containers.

| Option        | Description                                                                                                                              | Copy paste snippet                                           | Example values           |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------ |
| `tagPrefix`   | add `<Text>` to the beginning of every `sourcegraph/*` image tag, e.x.: `index.docker.io/sourcegraph/frontend:MY-PREFIX-3.21@sha256:123` | `with Global.ImageManipulations.tagPrefix = Optional <Text>` | `Some "MY-PREFIX"`       |
| `tagSuffix`   | add `<Text>` to the end of every `sourcegraph/*` image tag , e.x.: `index.docker.io/sourcegraph/frontend:3.21-MY-SUFFIX@sha256:123`      | `with Global.ImageManipulations.tagSuffix = Optional <Text>` | `Some "MY-SUFFIX"`       |
| `tag`         | replace the tag entirely for every `sourcegraph/*` image, e.x.: `index.docker.io/sourcegraph/frontend:MY-TAG@sha256:123`                 | `with Global.ImageManipulations.tag = Optional <Text>`       | `Some "TAG"`             |
| `stripDigest` | remove the sha256 digest for every `sourcegraph/*` image, e.x.: `index.docker.io/sourcegraph/frontend:3.21`                              | `with Global.ImageManipulations.stripDigest = Boolean`       | `False`                  |
| `registry`    | replace the registry every `sourcegraph/*` image, e.x.: `my.registry.com/sourcegraph/frontend:3.21@sha256:123`                           | `with Global.ImageManipulations.registry = Optional <Text>`  | `Some "my.registry.com"` |

## Namespace

Set the `namespace` for all Sourcegraph Kubernetes resource definitions

**Customization snippet**:

```dhall
with Global.namespace = Some <Text>
```

**Example value**:

```dhall
Some "my-namespace"
```

## Storage class name

Set the name for the storage class to use for all Sourcegraph volume definitions

**Customization snippet**:

```dhall
with Global.storageClassname = Some <Text>
```

**Example value**:

```dhall
Some "my-storage-class"
```

## Non-root users/groups

Whether or not to set all Sourcegraph containers to use nonRoot users and groups

**Customization snippet**:

```dhall
with Global.nonRoot = <Boolean>
```

**Example value**:

```dhall
False
```
