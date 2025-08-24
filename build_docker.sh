#!/bin/bash

docker buildx build \
  --load \
  --progress=plain \
  --build-arg HOST_USER="$(whoami)" \
  --build-arg USERNAME="$(id -un)" \
  --build-arg HOST_UID="$(id -u)" \
  --build-arg HOST_GID="$(id -g)" \
  --tag dev-env:latest .
