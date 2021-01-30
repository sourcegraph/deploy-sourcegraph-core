let Generate/Deployment = ./generate/deployment/deployment.dhall

let Generate/Service/query = ./generate/service/jaeger-query.dhall

let Configuration/global = ../../configuration/global.dhall

let shape = ./shape.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let generate
    : Configuration/global.Type → shape
    = λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        in  { Deployment.jaeger = Generate/Deployment config.Deployment.jaeger
            , Service.jaeger-collector
              = Generate/Service/query config.Service.jaeger-collector
            , Service.jaeger-query
              = Generate/Service/query config.Service.jaeger-query
            }

in  generate
