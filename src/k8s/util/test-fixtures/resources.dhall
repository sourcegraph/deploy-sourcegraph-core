let Kubernetes/ResourceRequirements =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let ContainerResources = ../container-resources/package.dhall

let InputResources =
      ContainerResources.Requirements::{
      , limits =
        { memory = Some "1G"
        , cpu = Some "50m"
        , ephemeralStorage = Some "2G"
        , storage = Some "10G"
        }
      , requests =
        { memory = Some "3G"
        , cpu = Some "10m"
        , ephemeralStorage = Some "100MB"
        , storage = Some "100G"
        }
      }

let ExpectedResources =
      Some
        Kubernetes/ResourceRequirements::{
        , limits = Some
          [ { mapKey = "cpu", mapValue = "50m" }
          , { mapKey = "memory", mapValue = "1G" }
          , { mapKey = "ephemeral-storage", mapValue = "2G" }
          , { mapKey = "storage", mapValue = "10G" }
          ]
        , requests = Some
          [ { mapKey = "cpu", mapValue = "10m" }
          , { mapKey = "memory", mapValue = "3G" }
          , { mapKey = "ephemeral-storage", mapValue = "100MB" }
          , { mapKey = "storage", mapValue = "100G" }
          ]
        }

let EmptyInput = ContainerResources.Requirements::{=}

let EmptyExpected = None Kubernetes/ResourceRequirements.Type

let Resources =
      { Input = InputResources
      , EmptyInput
      , EmptyExpected
      , Expected = ExpectedResources
      }

in  Resources
