let Configuration = ./configuration/global.dhall

let Kubernetes = ../deps/k8s/schemas.dhall

let Generate = ./generate.dhall

in  { Configuration, Kubernetes, Generate }
