#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/..
set -euxo pipefail

just sync-ds

IMAGES_FILE="${IMAGES_FILE:-"./src/simple/images.dhall"}"

git diff --exit-code "${IMAGES_FILE}"
