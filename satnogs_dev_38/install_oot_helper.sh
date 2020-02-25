#!/bin/bash -e

source gnuradio.env
if [ -z ${PREFIX+x} ] ; then
  echo Use args: $0 repo [branch]
  echo Environment variable PREFIX not defined, exiting.
  exit 1
fi

REPO=$1
BRANCH_STRING=""
if [ -n "${2+x}" ]; then
  BRANCH=$2
  BRANCH_STRING="-b ${BRANCH}"
fi

echo Specified oot module repo: $REPO
echo Specied branch: $BRANCH

# Remove path
REPO_DIR="${REPO##*/}"
# Remove extension
REPO_DIR=${REPO_DIR%.*}
echo Probably checked out to: $REPO_DIR
git clone --recursive ${BRANCH_STRING} ${REPO}
mkdir -p $REPO_DIR/build
pushd $REPO_DIR/build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DPYTHON_EXECUTABLE=$(which python3) ..
make -j8 install
popd



