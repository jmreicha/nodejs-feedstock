#!/usr/bin/env bash

# Because this build is already running in a container we don't do the docker
# run.  Likewise, the directories aren't volume mounted so we use the Drone values
# instead.  Also note that environment variables are set in the .drone.yml file
# and passed into this script since docker run isn't used.

set -xeuo pipefail

# Activate the conda environment first
. /opt/conda/bin/activate

# Set up the directories here needed for the build script
export FEEDSTOCK_ROOT="${CI_WORKSPACE}"
export RECIPE_ROOT="${FEEDSTOCK_ROOT}/recipe"
export ARTIFACTS="${FEEDSTOCK_ROOT}/build_artifacts"

if [ -z "$CONFIG" ]; then
    set +x
    FILES=`ls .ci_support/linux_*`
    CONFIGS=""
    for file in $FILES; do
        CONFIGS="${CONFIGS}'${file:12:-5}' or ";
    done
    echo "Need to set CONFIG env variable. Value can be one of ${CONFIGS:0:-4}"
    exit 1
fi

mkdir -p "$ARTIFACTS"
DONE_CANARY="$ARTIFACTS/conda-forge-build-done-${CONFIG}"
rm -f "$DONE_CANARY"

# Conda build
./build_steps.sh

# verify that the end of the script was reached
test -f "$DONE_CANARY"
