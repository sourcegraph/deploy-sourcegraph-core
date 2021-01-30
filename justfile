all: check freeze format lint build

build: render-ci-pipeline render-pipelines

render-ci-pipeline:
    ./scripts/render-ci-pipeline.sh

fmt: format

format: format-dhall prettier format-shfmt

lint: lint-dhall shellcheck

freeze: freeze-dhall

check: check-dhall

check-pkg: check-package

check-package: check-dhall-package

prettier:
    yarn run prettier

build-k8s:
    dhall-to-yaml --explain --file=src/k8s/pipeline.dhall

build-docker-compose:
    dhall-to-yaml --explain --file=src/docker-compose/frontend-pipeline.dhall

check-dhall:
    ./scripts/dhall-check.sh

k8s-package-file := "./src/k8s/package.dhall"

check-dhall-package:
    ./scripts/dhall-check.sh '{{k8s-package-file}}'

format-dhall:
    ./scripts/dhall-format.sh

freeze-dhall:
    ./scripts/dhall-freeze.sh

lint-dhall:
    ./scripts/dhall-lint.sh

shellcheck:
    ./scripts/shellcheck.sh

sync-ds:
    ./scripts/sync-ds.sh

render-pipelines: render-k8s-pipeline

render-k8s-pipeline:
    ./scripts/render-k8s-pipeline.sh

format-shfmt:
    shfmt -w .

install:
    just install-asdf
    just install-yarn

install-yarn:
    yarn

install-asdf:
    asdf install

deploy-sourcegraph-file := "./deploy-sourcegraph.dhall"
pipeline-file := "./src/k8s/pipeline.dhall"

diff-ds:
    dhall diff '({{deploy-sourcegraph-file}}).jaeger' '({{pipeline-file}}).jaeger'

rewrite: rewrite-ds

k8s-schemas-file := "./src/deps/k8s/schemas.dhall"

rewrite-ds:
    dhall rewrite-with-schemas --inplace '{{deploy-sourcegraph-file}}' --schemas '{{k8s-schemas-file}}'
