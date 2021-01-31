let Gitserver/shape = ./components/gitserver/shape.dhall

let Symbols/shape = ./components/symbols/shape.dhall

let RepoUpdater/shape = ./components/repo-updater/shape.dhall

let Grafana/shape = ./components/grafana/shape.dhall

let QueryRunner/shape = ./components/query-runner/shape.dhall

let GithubProxy/shape = ./components/github-proxy/shape.dhall

let Postgres/shape = ./components/postgres/shape.dhall

let CAdvisor/shape = ./components/cadvisor/shape.dhall

let Minio/shape = ./components/minio/shape.dhall

let Searcher/shape = ./components/searcher/shape.dhall

let Jaeger/shape = ./components/jaeger/shape.dhall

let IndexedSearch/shape = ./components/indexed-search/shape.dhall

in  { gitserver : Gitserver/shape
    , symbols : Symbols/shape
    , repo-updater : RepoUpdater/shape
    , grafana : Grafana/shape
    , query-runner : QueryRunner/shape
    , github-proxy : GithubProxy/shape
    , pgsql : Postgres/shape
    , cadvisor : CAdvisor/shape
    , minio : Minio/shape
    , searcher : Searcher/shape
    , jaeger : Jaeger/shape
    , indexed-search : IndexedSearch/shape
    }
