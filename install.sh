#!/usr/bin/env bash
set -e

if [ "$VERSION" == "latest" ]; then
  VERSION=
fi
MAJOR_VERSION=${VERSION%%.*}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

check_packages lsb-release wget software-properties-common gnupg

cd /tmp
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh $VERSION all
rm llvm.sh

ln -sf /usr/bin/clang-${MAJOR_VERSION} /usr/bin/clang
ln -sf /usr/bin/clang++-${MAJOR_VERSION} /usr/bin/clang++
ln -sf /usr/bin/lld-${MAJOR_VERSION} /usr/bin/lld
ln -sf /usr/bin/ld.lld-${MAJOR_VERSION} /usr/bin/ld.lld
