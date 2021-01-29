#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
set -euxo pipefail

GIT_COMMIT="f4bf4b9ddf669f7149ec32150863a93d6c4b3ef1"

ARCHIVE="dhall-kubernetes.gz"

cleanup() {
  rm -rf "$ARCHIVE"
}
trap cleanup EXIT

wget -O "$ARCHIVE" "https://github.com/dhall-lang/dhall-kubernetes/tarball/${GIT_COMMIT}"

DESTINATION="k8s"
rm -rf "${DESTINATION:?}"/*
mkdir -p "${DESTINATION}"

KUBERNETES_VERSION="1.18"
tar -xvf "$ARCHIVE" --strip-components=2 -C "$DESTINATION" "dhall-lang-dhall-kubernetes-${GIT_COMMIT:0:7}/$KUBERNETES_VERSION"
