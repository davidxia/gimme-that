#!/usr/bin/env bash

# set -x
set -eo pipefail

# Colors for colorizing
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Storage for constants
TARGET_BIN=${TARGET_BIN:-"confd"}
# TODO: Make this dynamic
GITHUB_API=${GITHUB_API:-"https://api.github.com"}
TARGET_GITHUB_USER=${TARGET_GITHUB_USER:-"kelseyhightower"}
TARGET_GITHUB_REPO=${TARGET_GITHUB_REPO:-"confd"}
TARGET_INSTALL_PATH=${TARGET_INSTALL_PATH:-"/usr/local/bin"}
HOST_OS=${HOST_OS:-$(uname | tr '[:upper:]' '[:lower:]')}
if [[ $(uname -m) == "x86_64" ]]; then
  HOST_ARCH="amd64"
else
  HOST_ARCH=${HOST_ARCH:-$(uname -m)}
fi

# Basic JSON matching
# TODO: Clean this up
function jsonVal {
    temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2 | sed 's|.*\:\(.*\)|\1|'`
    echo ${temp##*|}
}

# Check GitHub for the latest release
URI=${GITHUB_API}/repos/${TARGET_GITHUB_USER}/${TARGET_GITHUB_REPO}/releases/latest
RELEASE_RESPONSE=$(curl -L -S -s ${URI})

# Parse release info
RELEASE_TAG=$(jsonVal "${RELEASE_RESPONSE}" "tag_name")
# TODO: Make this more flexible
TARGET_STRING=${TARGET_BIN}-${RELEASE_TAG}-${HOST_OS}-${HOST_ARCH}
# echo -e $TARGET_STRING
# TODO: Ditto. This makes me uber sad.
DOWNLOAD_URL="https://github.com/"${TARGET_GITHUB_USER}"/"${TARGET_GITHUB_REPO}"/releases/download/"${RELEASE_TAG}"/"${TARGET_STRING}
# echo -e $DOWNLOAD_URL

# Check if we have this already
if ! command -v ${TARGET_BIN}; then
  curl -s -S -L ${DOWNLOAD_URL} -o ${TARGET_INSTALL_PATH}/${TARGET_BIN}
  chmod +x ${TARGET_INSTALL_PATH}/${TARGET_BIN}
# else
  # TODO: Do some version checking here. Hash?
fi
