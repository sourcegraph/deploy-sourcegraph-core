let Configuration = ./configuration/global.dhall

let Kubernetes = ../deps/k8s/schemas.dhall

let Generate = ./generate.dhall

let Util =
      { EnvToK8s = ../util/functions/environment-to-k8s.dhall
      , Image = ../util/image.dhall
      }

in  { Configuration, Kubernetes, Generate, Util }
