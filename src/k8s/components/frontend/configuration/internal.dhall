let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let sharedConfiguration = ../../shared/shared.dhall

let environment = ./environment/environment.dhall

let ContainerConfiguration =
        { securityContext : Optional Kubernetes/SecurityContext.Type }
      ⩓ sharedConfiguration.ContainerConfiguration.Type

let FrontendContainer =
      ContainerConfiguration ⩓ { Environment : environment.Type }

let JaegerContainer = ContainerConfiguration

let Containers = { frontend : FrontendContainer, jaeger : JaegerContainer }

let Deployment = { Containers : Containers }

let configuration = { namespace : Optional Text, Deployment : Deployment }

in  configuration
