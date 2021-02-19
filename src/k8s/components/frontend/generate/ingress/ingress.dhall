let Kubernetes/ObjectMeta =
      ../../../../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/Ingress =
      ../../../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.Ingress.dhall

let Kubernetes/IngressSpec =
      ../../../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.IngressSpec.dhall

let Kubernetes/IngressRule =
      ../../../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.IngressRule.dhall

let Kubernetes/HTTPIngressRuleValue =
      ../../../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.HTTPIngressRuleValue.dhall

let Kubernetes/HTTPIngressPath =
      ../../../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.HTTPIngressPath.dhall

let Kubernetes/IngressBackend =
      ../../../../../deps/k8s/schemas/io.k8s.api.networking.v1beta1.IngressBackend.dhall

let Kubernetes/IntOrString =
      ../../../../../deps/k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

let Configuration/Internal/Ingress = ../../configuration/internal/ingress.dhall

let Fixtures/frontend/ingress = ./fixtures.dhall

let Fixtures/global = ../../../../util/test-fixtures/package.dhall

let Ingress/generate
    : ∀(c : Configuration/Internal/Ingress) → Kubernetes/Ingress.Type
    = λ(c : Configuration/Internal/Ingress) →
        let namespace = c.namespace

        let ingress =
              Kubernetes/Ingress::{
              , metadata = Kubernetes/ObjectMeta::{
                , namespace
                , labels = Some
                  [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
                  , { mapKey = "app.kubernetes.io/component"
                    , mapValue = "frontend"
                    }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , annotations = Some
                  [ { mapKey = "kubernetes.io/ingress.class"
                    , mapValue = "nginx"
                    }
                  , { mapKey = "nginx.ingress.kubernetes.io/proxy-body-size"
                    , mapValue = "150m"
                    }
                  ]
                , name = Some "sourcegraph-frontend"
                }
              , spec = Some Kubernetes/IngressSpec::{
                , rules = Some
                  [ Kubernetes/IngressRule::{
                    , http = Some Kubernetes/HTTPIngressRuleValue::{
                      , paths =
                        [ Kubernetes/HTTPIngressPath::{
                          , path = Some "/"
                          , backend = Kubernetes/IngressBackend::{
                            , serviceName = Some "sourcegraph-frontend"
                            , servicePort = Some
                                (Kubernetes/IntOrString.Int 30080)
                            }
                          }
                        ]
                      }
                    }
                  ]
                }
              }

        in  ingress

let tc = Fixtures/frontend/ingress.frontend.Config

let Test/namespace/none =
        assert
      :   (Ingress/generate (tc with namespace = None Text)).metadata.namespace
        ≡ None Text

let Test/namespace/some =
        assert
      :   ( Ingress/generate
              (tc with namespace = Some Fixtures/global.Namespace)
          ).metadata.namespace
        ≡ Some Fixtures/global.Namespace

in  Ingress/generate
