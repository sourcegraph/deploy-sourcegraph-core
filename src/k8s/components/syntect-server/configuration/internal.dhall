let Configuration/Internal/Service = ./internal/service.dhall

let Configuration/Internal/Deployment = ./internal/deployment.dhall

in  { Deployment : { syntect-server : Configuration/Internal/Deployment }
    , Service : { syntect-server : Configuration/Internal/Service }
    }
