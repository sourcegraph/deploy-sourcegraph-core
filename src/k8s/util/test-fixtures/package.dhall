let Configuration/global = ../../configuration/global.dhall

let BaseConfig = Configuration/global::{=}

let Config = { Default = BaseConfig }

let Namespace = "testNamespace"

in  { Config
    , Namespace
    , Replicas = 896
    , Containers = ./sidecars.dhall
    , SideCars = ./sidecars.dhall
    , Image = ./image.dhall
    , Resources = ./resources.dhall
    , Volumes = ./volumes.dhall
    , VolumeMounts = ./volumeMounts.dhall
    , Environment = ./environment.dhall
    , SecurityContext = ./securityContext.dhall
    , PersistentVolumeClaim = ./persistentVolumeClaim.dhall
    }
