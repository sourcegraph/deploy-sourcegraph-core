let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let cgContainers = cg.frontend.Deployment.Containers

        let manipulate/options = globalOpts.ImageManipulations

        let frontendImage =
              Image/manipulate manipulate/options cgContainers.frontend.image

        let jaegerImage =
              Image/manipulate manipulate/options cgContainers.jaeger.image

        let FrontendConfig =
              cg.frontend.Deployment.Containers.frontend
              with image = frontendImage
              with securityContext = securityContext

        let JaegerConfig =
              cg.frontend.Deployment.Containers.jaeger
              with image = jaegerImage
              with securityContext = securityContext

        in  { namespace = globalOpts.namespace
            , Deployment.Containers
              =
              { frontend = FrontendConfig, jaeger = JaegerConfig }
            }

in  toInternal
