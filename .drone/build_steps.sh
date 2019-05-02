#!/usr/bin/env bash

# PLEASE NOTE: This script has been automatically generated by conda-smithy. Any changes here
# will be lost next time ``conda smithy rerender`` is run. If you would like to make permanent
# changes to this script, consider a proposal to conda-smithy so that other feedstocks can also
# benefit from the improvement.

set -euo pipefail

# Conda setup

# Use non-interactive cp
#unalias cp
# Create conda user with the same uid as the host, so the container can write
# to mounted volumes
# Adapted from https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
USER_ID=${HOST_USER_ID:-9001}
useradd --shell /bin/bash -u "$USER_ID" -G lucky -o -c "" -m conda
export HOME=/home/conda
export USER=conda
export LOGNAME=conda
export MAIL=/var/spool/mail/conda
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/conda/bin
export supkg="su-exec"

chown conda:conda $HOME
cp -R /etc/skel $HOME && chown -R conda:conda $HOME/skel && (ls -A1 $HOME/skel | xargs -I {} mv -n $HOME/skel/{} $HOME) && rm -Rf $HOME/skel
cp /root/.condarc $HOME/.condarc && chown conda:conda $HOME/.condarc
cd $HOME

# Source base Conda environment
. /opt/conda/bin/activate

# Build

set -x

echo "dir: $(pwd)"

# TODO Figure out how to get /drone/src to /home/conda

export PYTHONUNBUFFERED=1
#export FEEDSTOCK_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
export FEEDSTOCK_ROOT="${CI_WORKSPACE}/${DRONE_REPO_NAME}"
export RECIPE_ROOT="${FEEDSTOCK_ROOT}/recipe"
export CI_SUPPORT="${FEEDSTOCK_ROOT}/.ci_support"
export ARTIFACTS="${FEEDSTOCK_ROOT}/build_artifacts"
#export FEEDSTOCK_ROOT=/home/conda/feedstock_root
#export RECIPE_ROOT=/home/conda/recipe_root
#export CI_SUPPORT=/home/conda/feedstock_root/.ci_support
export CONFIG_FILE="${CI_SUPPORT}/${CONFIG}.yaml"

mkdir -p "${ARTIFACTS}"

#root-dir: /home/conda/feedstock_root/build_artifacts

cat >~/.condarc <<CONDARC

conda-build:
 root-dir: ${ARTIFACTS}

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
