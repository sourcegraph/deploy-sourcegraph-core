#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/..
set -eu pipefail

DHALL_FILES=()

mapfile -t DHALL_FILES < <(scripts/ls-dhall-files.sh)

# https://unix.stackexchange.com/a/256201
function my_chronic() {
  tmp=$(mktemp) || return # this will be the temp file w/ the output
  "$@" >"$tmp" 2>&1       # this should run the command, respecting all arguments
  ret=$?
  [ "$ret" -eq 0 ] || cat "$tmp" # if $? (the return of the last run command) is not zero, cat the temp file
  rm -f "$tmp"
  return "$ret" # return the exit status of the command
}

export -f my_chronic

function freeze() {
  local file="$1"

  local FREEZE_ARGS=(
    "dhall"
    "freeze"
    "--inplace"
    "${file}"
  )

  if [ "${CHECK:-"false"}" == "true" ]; then
    FREEZE_ARGS+=("--check")
  fi

  result=$(my_chronic "${FREEZE_ARGS[@]}" 2>&1)
  rc=$?

  if [ -n "$result" ]; then
    echo "${file}:"
    echo "$result"
    echo
  fi

  return "$rc"
}
export -f freeze

./scripts/parallel_run.sh freeze {} ::: "${DHALL_FILES[@]}"
