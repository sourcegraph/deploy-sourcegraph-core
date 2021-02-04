let Gitserver/generate-list = ./components/gitserver/generate-list.dhall

let Symbols/generate-list = ./components/symbols/generate-list.dhall

let RepoUpdater/generate-list = ./components/repo-updater/generate-list.dhall

let Grafana/generate-list = ./components/grafana/generate-list.dhall

let GithubProxy/generate-list = ./components/github-proxy/generate-list.dhall

let QueryRunner/generate-list = ./components/query-runner/generate-list.dhall

let Postgres/generate-list = ./components/postgres/generate-list.dhall

let Searcher/generate-list = ./components/searcher/generate-list.dhall

let IndexedSearch/generate-list =
      ./components/indexed-search/generate-list.dhall

let Redis/generate-list = ./components/redis/generate-list.dhall

let Kubernetes/Union = ./union.dhall

let Configuration/global = ./configuration/global.dhall

let generate-list
    : ∀(c : Configuration/global.Type) → List Kubernetes/Union
    = λ(c : Configuration/global.Type) →
        let xs = GithubProxy/generate-list c

        let xs = xs # Gitserver/generate-list c

        let xs = xs # Symbols/generate-list c

        let xs = xs # RepoUpdater/generate-list c

        let xs = xs # Grafana/generate-list c

        let xs = xs # QueryRunner/generate-list c

        let xs = xs # Postgres/generate-list c

        let xs = xs # Searcher/generate-list c

        let xs = xs # IndexedSearch/generate-list c

        let xs = xs # Redis/generate-list c

        in  xs

in  generate-list
