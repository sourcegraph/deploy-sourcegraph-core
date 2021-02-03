let Image =
      { name : Text
      , tag : Text
      , registry : Optional Text
      , digest : Optional Text
      }

let Container = { image : Image }

let EnvVar = { name : Text, value : Optional Text }

let HealthCheck/Scheme = < HTTP >

let sharedFields =
      { retries : Optional Natural
      , initialDelaySeconds : Optional Natural
      , timeoutSeconds : Optional Natural
      , intervalSeconds : Optional Natural
      }

let Port = { number : Natural, name : Optional Text }

let NetworkHealth =
        sharedFields
      ⩓ { endpoint : Text, scheme : HealthCheck/Scheme, port : Port }

let Command = < Exec : List Text | Shell : List Text | Raw : Text >

let ExecHealth = sharedFields ⩓ { command : Command }

let HealthCheck = < Network : NetworkHealth | Exec : ExecHealth >

in  { Image
    , Container
    , EnvVar
    , HealthCheck
    , HealthCheck/Scheme
    , Command
    , ExecHealth
    , NetworkHealth
    , Port
    }
