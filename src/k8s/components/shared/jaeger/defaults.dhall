let Configuration/ResourceRequirements =
      (../../../util/container-resources/package.dhall).Requirements

let Simple/images = ../../../../simple/images.dhall

let Resources =
      Configuration/ResourceRequirements::{=}
      with limits.cpu = Some "1"
      with limits.memory = Some "500M"
      with requests.cpu = Some "100m"
      with requests.memory = Some "100M"

let Image = Simple/images.sourcegraph/jaeger-agent

in  { Image, Resources }
