#!/usr/bin/env bash

set -x

# scrub -std=... flag which conflicts with builds
export CXXFLAGS=$(echo ${CXXFLAGS:-} | sed -E 's@\-std=[^ ]*@@g')

echo "Test CPU count: $(grep -c ^processor /proc/cpuinfo)"
echo "Conda CPU count: ${CPU_COUNT}"
exit

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make -j${CPU_COUNT}
make install

node -v
npm version

