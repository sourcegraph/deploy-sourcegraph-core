let CAdvisor/configuration = ../components/cadvisor/configuration/user.dhall

let Frontend/configuration = ../components/frontend/configuration/user.dhall

let GithubProxy/configuration =
      ../components/github-proxy/configuration/user.dhall

let Gitserver/configuration = ../components/gitserver/configuration/user.dhall

let Symbols/configuration = ../components/symbols/configuration/user.dhall

let Grafana/configuration = ../components/grafana/configuration/user.dhall

let Postgres/configuration = ../components/postgres/configuration/user.dhall

let RepoUpdater/configuration =
      ../components/repo-updater/configuration/user.dhall

let QueryRunner/configuration =
      ../components/query-runner/configuration/user.dhall

let Searcher/configuration = ../components/searcher/configuration/user.dhall

let Minio/configuration = ../components/minio/configuration/user.dhall

let Redis/configuration = ../components/redis/configuration/user.dhall

let Jaeger/configuration = ../components/jaeger/configuration/user.dhall

let IndexedSearch/configuration =
      ../components/indexed-search/configuration/user.dhall

let Image/manipulate/options =
      (../../util/functions/image-manipulate.dhall).Image/manipulate/options

let configuration =
      { Type =
          { Global :
              { ImageManipulations : Image/manipulate/options.Type
              , nonRoot : Bool
              , namespace : Optional Text
              , storageClassname : Optional Text
              }
          , cadvisor : CAdvisor/configuration.Type
          , frontend : Frontend/configuration.Type
          , github-proxy : GithubProxy/configuration.Type
          , gitserver : Gitserver/configuration.Type
          , symbols : Symbols/configuration.Type
          , repo-updater : RepoUpdater/configuration.Type
          , grafana : Grafana/configuration.Type
          , query-runner : QueryRunner/configuration.Type
          , searcher : Searcher/configuration.Type
          , pgsql : Postgres/configuration.Type
          , minio : Minio/configuration.Type
          , jaeger : Jaeger/configuration.Type
          , indexed-search : IndexedSearch/configuration.Type
          , redis : Redis/configuration.Type
          }
      , default =
        { Global =
          { ImageManipulations = Image/manipulate/options.default
          , nonRoot = False
          , namespace = None Text
          , storageClassname = Some "sourcegraph"
          }
        , cadvisor = CAdvisor/configuration.default
        , frontend = Frontend/configuration.default
        , github-proxy = GithubProxy/configuration.default
        , gitserver = Gitserver/configuration.default
        , symbols = Symbols/configuration.default
        , repo-updater = RepoUpdater/configuration.default
        , grafana = Grafana/configuration.default
        , query-runner = QueryRunner/configuration.default
        , searcher = Searcher/configuration.default
        , pgsql = Postgres/configuration.default
        , minio = Minio/configuration.default
        , jaeger = Jaeger/configuration.default
        , indexed-search = IndexedSearch/configuration.default
        , redis = Redis/configuration.default
        }
      }

in  configuration
