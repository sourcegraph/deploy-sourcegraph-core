# Background

This document describes the organizational principles of Sourcegraph deployment specifications written in Dhall.

The document mentions Dhall language constructs like record, record type and record schema. A passing knowledge
of these terms is helpful in understanding this document. A good introduction for learning Dhall is the
[Dhall Language Tour](https://docs.dhall-lang.org/tutorials/Language-Tour.html).

The three most useful Dhall language concepts are briefly defined as follows:

- [**record**](https://docs.dhall-lang.org/tutorials/Language-Tour.html#records) is an unordered collection of key-value pairs. Keys are strings. Values are any legal Dhall value.
  A Dhall record is therefore similar to JSON/YAML records or structs in Go.
- **record type** is defined by the types of the values from the key-value pairs.
- **record schema** is a record type which also allows for [defining default values for the record keys](https://docs.dhall-lang.org/tutorials/Language-Tour.html#record-completion).

## Structure

### COMKIR

COMKIR represents a hierarchy defined by the scheme "**Com**ponent -> **Ki**nd -> **R**esource".

A Kubernetes (k8s) deployment of Sourcegraph is specified by a set of Kubernetes manifests that each declare a Kubernetes
resource. In a Sourcegraph cluster there are multiple services talking to each other, so it makes sense to group the various
manifests by the services they belong to. All the Kubernetes resources that belong to one service form a `component`.

For example the `frontend` component has a deployment, 2 services, an ingress, a role binding, a role and
a service account. The `gitserver` component has a statefulset and a service. Each of these members of a component
are Kubernetes resources specified by a manifest. A Kubernetes resource is of a specific type which is defined
by the `kind` key in the manifest. The `frontend` component for example has two Kubernetes resources of kind
`Service`.

To keep organizing even deeper we can group Kubernetes resources in each component by their `kind`. Because a
component can have more than one Kubernetes resource of a `kind` we can use the resource name to distinguish them.

The final organizational tree of Kubernetes resources looks like this:

```text
base
│ ...
├── frontend
│  ├── deployment
│  │  └── sourcegraph-frontend
│  ├── role
│  │  └── sourcegraph-frontend
│  ├── rolebinding
│  │  └── sourcegraph-frontend
│  ├── service
│  │  ├── sourcegraph-frontend-internal
│  │  └── sourcegraph-frontend
│  └── serviceaccount
│     └── sourcegraph-frontend
│ ...
├── gitserver
│  ├── service
│  │  └── gitserver
│  └── statefulset
│     └── gitserver
│ ...
```

The leaves of this organizational tree are Kubernetes resources. All the paths in the tree to the leaves have the form
`component name -> kind -> resource name`. We call this organizational form COMKIR. We will use it to organize any trees
of records where the records come from or are associated with our components.

![comkir](imgs/comkir.png?raw=true 'COMKIR')

### Component parts

A component defines several record types/schemas and functions.

![component](imgs/component.png?raw=true 'Component')

- `user.dhall`: defines a record schema of user customizations for the component. An example customization would be the memory
  limit on a particular container in one of the deployments of the component. All the user customizations supported
  by a component are described in a `documentation.md` document.
- `internal.dhall`: defines a record type. A record of this type holds all the data necessary to create the Kubernetes
  manifestation of the component (see `shape.dhall` for details of that manifestation).
- `toInternal.dhall`: defines a function that has as input a record of type as defined in `user.dhall` and has as output
  a record of type as defined in `internal.dhall`. It transforms user customizations into the internal representation
  by combining the user customizations with hardcoded k8s defaults and defaults shared with the docker compose deployment
  and defined in the `simple` Dhall package.
- `generate.dhall`: defines a function that has as input the aggregated record of user customizations (see the
  `Pipeline and Aggregate records` section for details) and as output a record of type as defined in `shape.dhall`.
- `shape.dhall`: defines a record type holding all the Kubernetes resources of the component organized by COMKIR from
  the component level downwards.

> Note: the choice of `user` being a schema and `internal` a type is intentional. We don't want to force users
> to specify null values for things they do not want to customize and leave as default. With a schema they only have
> to specify things that they actually want to customize. `internal` on the other hand is a type to enforce the fact
> that everything needed to generate a shape is provided intentionally and nothing is left outunspecified by mistake.

### Pipeline and Aggregate records

The Dhall Sourcegraph deployment specification is a pipeline with input a global customization record and output
an aggregated shape record.

Both the global customization record (`user.dhall`), and the aggregated shape record (`shape.dhall`) are organized by COMKIR.

![aggregate](imgs/aggregate.png?raw=true 'Aggregate')

### Data flow

The global customization record is passed into a central `generate` function that in turn calls the `generate` function
of each component and places the resulting `shape` records into the aggregated shape record that it outputs.

In pseudo-code it looks like this:

```text
generate(globalConfig):
     globalShape = new globalShape()
     for each component {
         componentShape = component/generate globalConfig
         globalShape.component = componentShape
     }
     return globalShape

 component/generate(globalConfig):
         internalConfig = toInternal globalConfig
         shape = new shape()
         for each kubernetes resource {
             shape.Kind.name = generate/kind/resource internalConfig.kind.resource
         }
        return shape
```

![data-flow](imgs/data-flow.png?raw=true 'Data flow')

### Why do the `internal` types exist at all?

> We want the flexibility to have the user facing configuration have a radically different structure than the raw kubernetes types. We’re still relatively early on in the customization process, so many of our customizations are relatively rote at the moment. However , I can imagine something really extensive such as turning on Vault which is going to touch a lot of different services. I don’t think it is a good user experience to expose the raw underlying Kubernetes types (container manipulations, configmaps, security groups, etc. as those are all mostly implementation details that have no direct relevance to the user (“I just wanted to turn vault on”). So, now we have the concept of “user facing” configuration. This user facing configuration needs to be translated to the raw Kubernetes types somehow.
>
> Some direct feedback that I got on my first POC way back when was that having the global configuration be consumed directly by `generate()` introduces a lot of cognitive overload. I agree with that feedback! Kubernetes manifests have a ton of boilerplate, and laying all that stuff out is a lot to parse when you’re staring at the full manifest - let alone incorporating the user settings at the same time. This is only going to get worse as we add more, complex customizations.
>
> So, in my mind, it makes sense to isolate these problems.
>
> The `generate` functions only concern themselves with laying out the manifests, and can ignore whatever is going on with the user configuration. All these functions just need to advertise what the “holes” are in their manifests (the `internal` types). Then all these functions grab the values from the input. These values are already kubernetes-native objects, so they can just slap them in the appropriate slot. Done. No extra function calls, No extra higher order logic, etc. They don’t need care about what’s going at the user level or about any future refactors that we make to the user configuration- they’re insulated from all that. Laying out the manifests is a difficult enough job on its own. In addition, the `internal` types serve as explicit, clear documentation for what can change in the manifests for every resource.
>
> So, now the issue is how do we translate from the user’s settings to the raw kubernetes types that are fed into `generate` . That’s where `toInternal` comes in. This translation logic needs to live somewhere now that it’s no longer in `generate` for readability purposes. Separating it out allows use to focus on just the translation instead of also getting overwhelmed with the rest of the manifest boilerplate at the same time. In addition, multiple customizations might end up affecting the same kubernetes object (e.g. vault and non-root both affect securitycontext, image overrides merging with an explicit provided image, etc.). Laying it out here allows us to write helper functions which canonicalize the behavior for what should happen in these situations without needing to spread out this resolution logic across multiple `generate` functions.

See https://sourcegraph.slack.com/archives/C019XH1BYSX/p1611861199005600?thread_ts=1611804964.024500&cid=C019XH1BYSX
