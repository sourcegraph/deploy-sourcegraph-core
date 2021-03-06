let Gitserver/generate = ./components/gitserver/generate.dhall

let Symbols/generate = ./components/symbols/generate.dhall

let RepoUpdater/generate = ./components/repo-updater/generate.dhall

let Grafana/generate = ./components/grafana/generate.dhall

let GithubProxy/generate = ./components/github-proxy/generate.dhall

let QueryRunner/generate = ./components/query-runner/generate.dhall

let Postgres/generate = ./components/postgres/generate.dhall

let CAdvisor/generate = ./components/cadvisor/generate.dhall

let Minio/generate = ./components/minio/generate.dhall

let Searcher/generate = ./components/searcher/generate.dhall

let Syntect-server/generate = ./components/syntect-server/generate.dhall

let IndexedSearch/generate = ./components/indexed-search/generate.dhall

let Codeintel-db/generate = ./components/codeintel-db/generate.dhall

let Redis/generate = ./components/redis/generate.dhall

let Frontend/generate = ./components/frontend/generate.dhall

let Shape = ./shape.dhall

let Jaeger/generate = ./components/jaeger/generate.dhall

let Configuration/global = ./configuration/global.dhall

let generate
    : ∀(c : Configuration/global.Type) → Shape
    = λ(c : Configuration/global.Type) →
        { github-proxy = GithubProxy/generate c
        , gitserver = Gitserver/generate c
        , symbols = Symbols/generate c
        , syntect-server = Syntect-server/generate c
        , repo-updater = RepoUpdater/generate c
        , grafana = Grafana/generate c
        , query-runner = QueryRunner/generate c
        , pgsql = Postgres/generate c
        , cadvisor = CAdvisor/generate c
        , minio = Minio/generate c
        , searcher = Searcher/generate c
        , jaeger = Jaeger/generate c
        , indexed-search = IndexedSearch/generate c
        , redis = Redis/generate c
        , codeintel-db = Codeintel-db/generate c
        , frontend = Frontend/generate c
        }

in  generate
