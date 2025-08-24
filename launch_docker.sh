#!/bin/bash

project_root="$HOME/workspace"
cache_volume="dev-env-ccache"
export LOCAL_UID=$(id -u)
export LOCAL_GID=$(id -g)

docker volume create "$cache_volume"

docker run --rm -it \
  --name dev-env \
  --user "$(id -u):$(id -g)" \
  -e TERM="$TERM" \
  -u "$(id -u):$(id -g)" \
  -v "$HOME/.bashrc":/home/jtown/.bashrc:ro \
  -v "$project_root":/workspace \
  -v "$cache_volume":/ccache \
  -w "/workspace" \
  --entrypoint bash \
  dev-env:latest -i

