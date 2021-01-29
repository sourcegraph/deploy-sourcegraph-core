let util = ../../util/package.dhall

let Simple/QueryRunner =
      (../../simple/query-runner/package.dhall).Containers.query-runner

let configuration =
      { Type = { image : util.Image.Type }
      , default.image = Simple/QueryRunner.image
      }

in  { configuration }
