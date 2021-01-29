let types = ./types.dhall

let Image = ./image.dhall

let Container = { Type = types.Container, default = {=} }

let EnvVar = { Type = types.EnvVar, default.value = Some "" }

let sharedFields =
      { retries = None Natural
      , initialDelaySeconds = None Natural
      , intervalSeconds = None Natural
      , timeoutSeconds = None Natural
      }

let NetworkHealthCheck =
      { Type = types.NetworkHealth, default = { endpoint = "" } ∧ sharedFields }

let ExecHealthCheck = { Type = types.ExecHealth, default = sharedFields }

in  { Image, Container, EnvVar, NetworkHealthCheck, ExecHealthCheck }
