#!/usr/bin/env bash
set -e

if [ "$VERSION" == "latest" ]; then
  VERSION=
fi

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

# Hack for apt-add-repository bug on Debian bookworm
# https://github.com/hof/bookworm-apt-add-repository-issue
if [ ! -f "/etc/apt/sources.list" ]; then
  echo '#' > /etc/apt/sources.list
fi

cd /tmp
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh $VERSION all
rm llvm.sh

# Remove downloads to keep Docker layer small
apt-get clean -y && rm -rf /var/lib/apt/lists/*

llvm_root_prefix=/usr/lib/llvm-

if [ -z $VERSION ]; then
  # Detect the latest version if it is "latest".
  llvm_latest_version=
  for llvm in ${llvm_root_prefix}*; do
    llvm_version=${llvm##$llvm_root_prefix}
    if [ ! -f ${llvm_root_prefix}${llvm_version}/bin/llvm-config ]; then
      continue
    fi
    if [[ -z $llvm_latest_version || llvm_version -gt llvm_latest_version ]]; then
      llvm_latest_version=$llvm_version
    fi
  done
  VERSION=$llvm_latest_version
fi

llvm_root=${llvm_root_prefix}${VERSION}

for bin in $llvm_root/bin/*; do
  bin=$(basename $bin)
  if [ -f /usr/bin/$bin-$VERSION ]; then
    ln -sf /usr/bin/$bin-$VERSION /usr/bin/$bin
  fi
done
