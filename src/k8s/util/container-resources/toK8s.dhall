let List/null =
      https://prelude.dhall-lang.org/v18.0.0/List/null.dhall sha256:2338e39637e9a50d66ae1482c0ed559bbcc11e9442bfca8f8c176bbcd9c4fc80

let Map/entry =
      https://prelude.dhall-lang.org/v18.0.0/Map/Entry.dhall sha256:f334283bdd9cd88e6ea510ca914bc221fc2dab5fb424d24514b2e0df600d5346

let Optional/null =
      https://prelude.dhall-lang.org/v18.0.0/Optional/null.dhall sha256:3871180b87ecaba8b53fffb2a8b52d3fce98098fab09a6f759358b9e8042eedc

let KeyValue = Map/entry Text Text

let KeyValueList = List KeyValue

let Kubernetes/ResourceRequirements =
      ../../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let ResourceRequirements = ./resource-requirements.dhall

let Configuration = ./resource-configuration.dhall

let configurationToK8s
    : Configuration.Type → Optional (List { mapKey : Text, mapValue : Text })
    = λ(c : Configuration.Type) →
        let memoryItem =
              merge
                { Some = λ(x : Text) → [ { mapKey = "memory", mapValue = x } ]
                , None = [] : KeyValueList
                }
                c.memory

        let cpuItem =
              merge
                { Some = λ(x : Text) → [ { mapKey = "cpu", mapValue = x } ]
                , None = [] : KeyValueList
                }
                c.cpu

        let ephemeralStorage =
              merge
                { Some =
                    λ(x : Text) →
                      [ { mapKey = "ephemeral-storage", mapValue = x } ]
                , None = [] : KeyValueList
                }
                c.ephemeralStorage

        let storage =
              merge
                { Some = λ(x : Text) → [ { mapKey = "storage", mapValue = x } ]
                , None = [] : KeyValueList
                }
                c.storage

        let all = cpuItem # memoryItem # ephemeralStorage # storage

        in  if List/null KeyValue all then None KeyValueList else Some all

let isNull
    : ∀(o : Optional KeyValueList) → Bool
    = λ(o : Optional KeyValueList) → Optional/null KeyValueList o

let tok8s
    : ResourceRequirements.Type → Optional Kubernetes/ResourceRequirements.Type
    = λ(r : ResourceRequirements.Type) →
        let limits = configurationToK8s r.limits

        let requests = configurationToK8s r.requests

        in  if    isNull limits && isNull requests
            then  None Kubernetes/ResourceRequirements.Type
            else  Some { limits, requests }

let tests =
      { t1 =
            assert
          :   tok8s
                { limits = Configuration::{
                  , cpu = Some "2"
                  , memory = Some "20Gi"
                  }
                , requests = Configuration::{
                  , cpu = Some "500m"
                  , ephemeralStorage = Some "100MB"
                  }
                }
            ≡ Some
                { limits = Some
                  [ { mapKey = "cpu", mapValue = "2" }
                  , { mapKey = "memory", mapValue = "20Gi" }
                  ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "500m" }
                  , { mapKey = "ephemeral-storage", mapValue = "100MB" }
                  ]
                }
      , t2 =
            assert
          :   tok8s
                { limits = Configuration::{ ephemeralStorage = Some "200MB" }
                , requests = Configuration::{
                  , cpu = Some "500m"
                  , memory = Some "100MB"
                  }
                }
            ≡ Some
                { limits = Some
                  [ { mapKey = "ephemeral-storage", mapValue = "200MB" } ]
                , requests = Some
                  [ { mapKey = "cpu", mapValue = "500m" }
                  , { mapKey = "memory", mapValue = "100MB" }
                  ]
                }
      , t3 =
            assert
          :   tok8s
                { limits = Configuration::{=}, requests = Configuration::{=} }
            ≡ None Kubernetes/ResourceRequirements.Type
      , t4 =
            assert
          :   tok8s
                { limits = Configuration::{=}
                , requests = Configuration::{ storage = Some "100Gi" }
                }
            ≡ Some
                { limits = None (List { mapKey : Text, mapValue : Text })
                , requests = Some [ { mapKey = "storage", mapValue = "100Gi" } ]
                }
      }

in  tok8s
