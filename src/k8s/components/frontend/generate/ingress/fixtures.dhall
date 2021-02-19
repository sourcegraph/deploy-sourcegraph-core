let Configuration/Internal/Ingress =
      ../../configuration/internal/ingress.dhall

let TestConfig
    : Configuration/Internal/Ingress
    = {namespace = None Text}

in  { frontend.Config =TestConfig
    }
