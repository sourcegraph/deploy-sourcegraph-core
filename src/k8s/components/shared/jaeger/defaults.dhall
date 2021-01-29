let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let Image = (../../../../util/package.dhall).Image

let Resources =
      Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "1"
      with limits.memory = Some "500M"
      with requests.cpu = Some "100m"
      with requests.memory = Some "100M"

let Image =
      Image::{
      , registry = Some "index.docker.io"
      , name = "sourcegraph/jaeger-agent"
      , tag = "insiders"
      , digest = Some
          "626831a08a1cfbd4d66c84c0c57b995df6a36a80c37a0f419df73ec86088e908"
      }

in  { Image, Resources }
