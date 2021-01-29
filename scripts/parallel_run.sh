#!/usr/bin/env bash

if ! command -v parallel &>/dev/null; then
  echo "'GNU parallel' is not installed. Please install 'parallel' via 'brew install parallel' or from https://savannah.gnu.org/projects/parallel/."
  echo "🚨 Do not install the version of 'parallel' provided by 'moreutils'!"
  exit 1
fi

log_file=$(mktemp)
# shellcheck disable=SC2064
trap "rm -rf $log_file" EXIT

# Remove parallel citation log spam.
echo 'will cite' | parallel --citation &>/dev/null

PARALLEL_ARGS=(
  "--memfree"
  "500M"

  "--keep-order"

  "--joblog"
  "$log_file"

  "--line-buffer"
)

if [[ -n "${PARALLEL_LOAD_PERCENTAGE}" ]]; then
  # TODO: Disabled by default because it introduced too much slowdown as the codebase grows.
  # Revisit this if this becomes a problem later on.
  PARALLEL_ARGS+=("--load")
  PARALLEL_ARGS+=("${PARALLEL_LOAD_PERCENTAGE}%")
fi

if [[ "${PARALLEL_VERBOSE:-"false"}" == "true" ]]; then
  PARALLEL_ARGS+=("--verbose")
fi

if [[ "${CI:-"false"}" == "true" ]] || [[ "${PARALLEL_VERBOSE:-"false"}" == "true" ]]; then
  PARALLEL_ARGS+=("--verbose")
fi

PARALLEL_ARGS+=("$@")

parallel "${PARALLEL_ARGS[@]}"
code=$?

if [[ "${CI:-"false"}" == "true" ]] || [[ "${PARALLEL_JOB_LOG:-"false"}" == "true" ]]; then
  echo "--- done - displaying job log:"
  cat "$log_file"
fi

exit $code
