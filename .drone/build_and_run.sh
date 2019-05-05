#!/usr/bin/env bash

# Because this build is already running in a container we don't do the docker
# run.  Likewise, the directories aren't volume mounted so we use the Drone values
# instead.  Also note that environment variables are set in the .drone.yml file
# and passed into this script since docker run isn't used.

set -xeuo pipefail

# Activate the conda environment first
. /opt/conda/bin/activate

FEEDSTOCK_ROOT="${CI_WORKSPACE}"
RECIPE_ROOT="${FEEDSTOCK_ROOT}/recipe"
ARTIFACTS="${FEEDSTOCK_ROOT}/build_artifacts"

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

#export PYTHONUNBUFFERED=1
#export FEEDSTOCK_ROOT=/home/conda/feedstock_root
#export RECIPE_ROOT=/home/conda/recipe_root
export CI_SUPPORT="${FEEDSTOCK_ROOT}/.ci_support"
export CONFIG_FILE="${CI_SUPPORT}/${CONFIG}.yaml"

cat >~/.condarc <<CONDARC

conda-build:
 root-dir: /home/conda/feedstock_root/build_artifacts

CONDARC

conda install --yes --quiet conda-forge-ci-setup=2 conda-build -c conda-forge

# set up the condarc
setup_conda_rc "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"

run_conda_forge_build_setup
# make the build number clobber
make_build_number "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"

conda build "${RECIPE_ROOT}" -m "${CI_SUPPORT}/${CONFIG}.yaml" \
    --clobber-file "${CI_SUPPORT}/clobber_${CONFIG}.yaml"

if [[ "${UPLOAD_PACKAGES}" != "False" ]]; then
    upload_package "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"
fi

touch "${ARTIFACTS}/conda-forge-build-done-${CONFIG}"
# verify that the end of the script was reached
test -f "$DONE_CANARY"
