#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/..
set -eu pipefail

LOCAL_PACKAGE_FILE="${LOCAL_PACKAGE_FILE:-"./src/k8s/package.dhall"}"

REMOTE_REF="${GITHUB_BASE_REF:-"main"}"

REMOTE_URL="https://raw.githubusercontent.com/sourcegraph/deploy-sourcegraph-core/${REMOTE_REF}/src/k8s/package.dhall"

dhall diff "${REMOTE_URL}" "${LOCAL_PACKAGE_FILE}"
