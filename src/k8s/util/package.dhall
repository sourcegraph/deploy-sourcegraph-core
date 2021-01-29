let containerResources = ./container-resources/package.dhall

in  { Volumes = ./volumes.dhall
    , Labels = ./labels.dhall
    , Octal = ./octal.dhall
    , ContainerResources = containerResources
    }
