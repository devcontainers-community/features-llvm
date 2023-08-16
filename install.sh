#!/usr/bin/env bash
set -e

apt update && apt install lsb-release wget software-properties-common gnupg -y -qq

bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

ln -s /usr/bin/clang-17 /usr/bin/clang
ln -s /usr/bin/clang++-17 /usr/bin/clang++
ln -s /usr/bin/lld-17 /usr/bin/lld
