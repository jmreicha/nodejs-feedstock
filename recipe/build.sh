#!/usr/bin/env bash

set -x

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

echo "Test CPU count: $(nproc)"
echo "Conda CPU count: ${CPU_COUNT}"

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make -j$(nproc)
make install

node -v
npm version

