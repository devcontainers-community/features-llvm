#!/bin/bash
set -e

ensure_apt_packages() (
  set -e

  export DEBIAN_FRONTEND=noninteractive
  if dpkg -s "$@" &>/dev/null; then
    echo "🟦 $@ is already installed"
  else
    if [[ $(find /var/lib/apt/lists/* | wc -l) == 0 ]]; then
      echo '🟪 Updating local apt index...'
      apt-get update -y
      echo '🟩 Updated local apt index'
    fi
    echo "🟪 Installing $@..."
    apt-get install -y --no-install-recommends "$@"
    echo "🟩 Installed $@"
  fi
)

clear_local_apt_index() (
  set -e
  
  rm -rf /var/lib/apt/lists/*
  echo '🟩 Cleared local apt index'
)

ensure_apt_packages curl ca-certificates jq

if [[ -z $VERSION || $VERSION == latest ]]; then
  echo "🟪 Fetching latest LLVM release..."
  curl -fsSLo latest-release.json https://api.github.com/repos/llvm/llvm-project/releases/latest
  version=$(jq -r .tag_name latest-release.json | sed 's/^llvmorg-//')
  echo "🟦 Using latest LLVM release: v$version"
else
  version="$VERSION"
  echo "🟦 Using LLVM release: v$version"
fi

ensure_apt_packages lsb-release wget software-properties-common gnupg

echo "🟪 Installing LLVM v$version..."
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh "$version"
echo "🟩 Installed LLVM v$version"

clear_local_apt_index
