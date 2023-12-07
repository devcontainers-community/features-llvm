#!/usr/bin/env bash
set -e

if [ "$VERSION" == "latest" ]; then
  VERSION=
fi
MAJOR_VERSION=${VERSION%%.*}

# Function to run apt-get if needed
apt_get_update_if_needed()
{
  if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
    echo "Running apt-get update..."
    apt-get update
  else
    echo "Skipping apt-get update."
  fi
}

# Checks if packages are installed and installs them if not
check_packages() {
  if ! dpkg -s "$@" > /dev/null 2>&1; then
    apt_get_update_if_needed
    apt-get -y install --no-install-recommends "$@"
  fi
}

check_packages lsb-release wget software-properties-common gnupg

# Remove any previous LLVM that may be in the base image
# LLVM packages packaged by Ubuntu may get picked over us and
# cause problems later.
if dpkg -s llvm > /dev/null 2>&1; then
  apt-get purge -y llvm && apt-get autoremove -y
fi

cd /tmp
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh $VERSION all
rm llvm.sh

# Remove downloads to keep Docker layer small
apt-get clean -y && rm -rf /var/lib/apt/lists/*

ln -sf /usr/bin/clang-${MAJOR_VERSION} /usr/bin/clang
ln -sf /usr/bin/clang++-${MAJOR_VERSION} /usr/bin/clang++
ln -sf /usr/bin/lld-${MAJOR_VERSION} /usr/bin/lld
ln -sf /usr/bin/ld.lld-${MAJOR_VERSION} /usr/bin/ld.lld
