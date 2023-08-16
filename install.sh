#!/usr/bin/env bash
set -e

apt update && apt install lsb-release wget software-properties-common gnupg -y -qq

bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
