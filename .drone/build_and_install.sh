#!/usr/bin/env bash

# PLEASE NOTE: This script has been automatically generated by conda-smithy. Any changes here
# will be lost next time ``conda smithy rerender`` is run. If you would like to make permanent
# changes to this script, consider a proposal to conda-smithy so that other feedstocks can also
# benefit from the improvement.

set -xeuo pipefail

# TODO Figure out slowness and don't export variables

# Conda setup

# Source the base Conda environment
. /root/archiconda3/bin/activate || true
. /opt/conda/bin/activate || true

# Build

export PYTHONUNBUFFERED=1
FEEDSTOCK_ROOT="${CI_WORKSPACE}"
RECIPE_ROOT="${FEEDSTOCK_ROOT}/recipe"
CI_SUPPORT="${FEEDSTOCK_ROOT}/.ci_support"
ARTIFACTS="${FEEDSTOCK_ROOT}/build_artifacts"
CONFIG_FILE="${CI_SUPPORT}/${CONFIG}.yaml"

mkdir -p "${ARTIFACTS}"

cat >~/.condarc <<CONDARC

conda-build:
  root-dir: ${ARTIFACTS}

CONDARC

conda info
cat /root/.condarc
exit
conda install --yes --quiet conda-forge-ci-setup=2 conda-build -c conda-forge

# TODO Seems like the issue is here
# set up the condarc
setup_conda_rc "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"

# Install additional tools for build
run_conda_forge_build_setup
# make the build number clobber
make_build_number "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"

conda build "${RECIPE_ROOT}" -m "${CONFIG_FILE}" \
    --clobber-file "${CI_SUPPORT}/clobber_${CONFIG}.yaml"

if [[ "${UPLOAD_PACKAGES}" != "False" ]]; then
    upload_package "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"
fi

touch "${ARTIFACTS}/conda-forge-build-done-${CONFIG}"
# verify that the end of the script was reached
#test -f "${ARTIFACTS}/conda-forge-build-done-${CONFIG}"
