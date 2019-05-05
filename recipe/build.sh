#!/usr/bin/env bash

set -x

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

if [ "$(uname -m)" = "armv8" ] || [ "$(uname -m)" = "ppc64le" ]; then
    echo "Using $(grep -c ^processor /proc/cpuinfo) CPUs"
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)
fi

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make -j$(nproc)
make install

node -v
npm version

