let Configuration = ./resource-configuration.dhall

in  { Type = { limits : Configuration.Type, requests : Configuration.Type }
    , default =
      { limits = Configuration.default, requests = Configuration.default }
    }
