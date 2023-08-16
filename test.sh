#!/bin/bash
set -ex
[[ -n $1 ]] && image=$1 || image='mcr.microsoft.com/devcontainers/base:debian'
[[ -n $2 ]] && options=$2 || options='{}'
feature_dir=$PWD
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' SIGINT SIGTERM ERR EXIT
pushd "$temp_dir"
mkdir -p .devcontainer
cat <<EOF | tee .devcontainer/devcontainer.json
{
  "image": "$image",
  "features": {
    "./feature": $options
  }
}
EOF
rsync -av --exclude .git "$feature_dir/" "$PWD/.devcontainer/feature/"
tree -a
container_id=$(devcontainer up --workspace-folder . | jq -r .containerId)
devcontainer exec --workspace-folder . clang --version
docker kill "$container_id"
