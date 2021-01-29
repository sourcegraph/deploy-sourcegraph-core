#!/usr/bin/env bash

set -eu pipefail

REPOSITORY_ROOT_RELATIVE_PATH="$(realpath --relative-to="$(pwd)" "$(dirname "${BASH_SOURCE[0]}")"/..)"

IGNORE_FILE="${REPOSITORY_ROOT_RELATIVE_PATH}/.fdignore-ls-dhall-files"

fd --ignore-file "${IGNORE_FILE}" --extension dhall . "${REPOSITORY_ROOT_RELATIVE_PATH}"
