#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/..
set -euo pipefail

CONFIGURATION_DEFAULTS_FILE="${CONFIGURATION_DEFAULTS_FILE:-"./src/k8s/configuration-default.dhall"}"

OUTPUT_FILE="${OUTPUT_FILE:-"./k8s-configuration-defaults.yaml"}"

set -x

dhall-to-yaml --file "${CONFIGURATION_DEFAULTS_FILE}" --output "${OUTPUT_FILE}" --preserve-null
