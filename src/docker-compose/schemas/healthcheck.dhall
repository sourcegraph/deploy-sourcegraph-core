let HealthCheck =
      { Type =
          { interval : Optional Text
          , retries : Optional Natural
          , start_period : Optional Text
          , test : ./healthcheck-test.dhall
          , timeout : Optional Text
          }
      , default =
        { interval = None Text
        , retries = None Natural
        , start_period = None Text
        , timeout = None Text
        }
      }

in  HealthCheck
