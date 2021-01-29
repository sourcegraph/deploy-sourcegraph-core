#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/..
set -euxo pipefail

PIPELINE_FILE=${PIPELINE_FILE:-"./src/k8s/pipeline.dhall"}
OUTPUT_FOLDER="./test-k8s-pipeline-output"

rm -rf "${OUTPUT_FOLDER}" || true

ds-to-dhall dhall2ds --output "${OUTPUT_FOLDER}" "${PIPELINE_FILE}"
