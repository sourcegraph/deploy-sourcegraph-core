let PersistentVolumeGeneratorFunctionType = ../persistentVolumeGenerator.dhall

let config =
      { namespace : Optional Text
      , replicas : Natural
      , pvg : Optional PersistentVolumeGeneratorFunctionType
      }

in  config
