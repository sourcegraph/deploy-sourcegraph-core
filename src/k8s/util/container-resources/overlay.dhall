let Configuration = ./resource-configuration.dhall

let overlayConfig
    : Configuration.Type → Configuration.Type → Configuration.Type
    = λ(base : Configuration.Type) →
      λ(overlay : Configuration.Type) →
        let overlayedMemory =
              merge
                { Some = λ(x : Text) → Some x, None = base.memory }
                overlay.memory

        let overlayedCPU =
              merge { Some = λ(x : Text) → Some x, None = base.cpu } overlay.cpu

        let overlayedEphemeralStorage =
              merge
                { Some = λ(x : Text) → Some x, None = base.ephemeralStorage }
                overlay.ephemeralStorage

        let ovelayedStorage =
              merge
                { Some = λ(x : Text) → Some x, None = base.storage }
                overlay.storage

        let result =
              { memory = overlayedMemory
              , cpu = overlayedCPU
              , ephemeralStorage = overlayedEphemeralStorage
              , storage = ovelayedStorage
              }

        in  result

let tests =
      { t1 =
            assert
          :   overlayConfig
                Configuration::{
                , memory = Some "20Gi"
                , cpu = Some "2"
                , storage = Some "50Gi"
                }
                Configuration::{
                , ephemeralStorage = Some "100MB"
                , cpu = Some "500m"
                , storage = Some "100Gi"
                }
            ≡ Configuration::{
              , ephemeralStorage = Some "100MB"
              , cpu = Some "500m"
              , memory = Some "20Gi"
              , storage = Some "100Gi"
              }
      , t2 =
            assert
          :   overlayConfig
                Configuration::{ cpu = Some "500m", memory = Some "200MB" }
                Configuration::{ cpu = Some "3" }
            ≡ Configuration::{ cpu = Some "3", memory = Some "200MB" }
      , t3 =
            assert
          :   overlayConfig
                Configuration::{ cpu = Some "500m", memory = Some "200MB" }
                Configuration::{ storage = Some "100Gi" }
            ≡ Configuration::{
              , cpu = Some "500m"
              , memory = Some "200MB"
              , storage = Some "100Gi"
              }
      }

in  overlayConfig
