let Configuration =
      { Type =
          { memory : Optional Text
          , cpu : Optional Text
          , ephemeralStorage : Optional Text
          , storage : Optional Text
          }
      , default =
        { memory = None Text
        , cpu = None Text
        , ephemeralStorage = None Text
        , storage = None Text
        }
      }

in  Configuration
