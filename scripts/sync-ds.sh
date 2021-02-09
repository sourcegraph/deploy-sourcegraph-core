#!/usr/bin/env bash

# Invokes ds-to-dhall on deploy-sourcegraph/base at specified commit.
# The commit is specifed with environment variable SYNC_DEPLOY_SOURCEGRAPH_COMMIT.
# The output is into fixed file deploy-sourcegraph.dhall.
# File is declared in .gitignore.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "$DIR"
set -euxo pipefail

SCRATCH_DIR=$(mktemp -d -t sync_ds_XXXXXXX)
function cleanup() {
  rm -rf "$SCRATCH_DIR"
}
trap cleanup EXIT

deploy_sourcegraph_commit=${SYNC_DEPLOY_SOURCEGRAPH_COMMIT:-master}

cd "${SCRATCH_DIR}"
git clone git@github.com:sourcegraph/deploy-sourcegraph.git
cd deploy-sourcegraph
git checkout "$deploy_sourcegraph_commit"

cd "$DIR"
ds-to-dhall ds2dhall -i kustomization.yaml -x k8sTypesUnion.dhall -o deploy-sourcegraph.dhall -u "$DIR"/src/deps/k8s "$SCRATCH_DIR"/deploy-sourcegraph/base
IMAGE_FILE="${DIR}/src/simple/images.dhall"
ds-to-dhall dockerimg "$SCRATCH_DIR"/deploy-sourcegraph/base >"${IMAGE_FILE}"
dhall format --inplace "${IMAGE_FILE}"
