#!/bin/bash
set -Eeuo pipefail
set -x

MAKE_ARGS="UNATTENDED=y V=${MAKE_VERBOSE} PLATFORM=${MAKE_PLATFORM} TAG=${MAKE_TAG}"
declare -a VPPSB_PLUGINS=(
	"netlink"
	"router"
	"turbotap"
)
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y git build-essential sudo python3

git clone https://github.com/FDio/vpp.git
git clone https://gerrit.fd.io/r/vppsb

cd vpp
git checkout "${VPP_BRANCH}"
make "${MAKE_ARGS}" install-dep
make "${MAKE_ARGS}" install-ext-deps
make "${MAKE_ARGS}" build-release
make "${MAKE_ARGS}" pkg-deb
make "${MAKE_ARGS}" vom-pkg-deb

for PLUGIN in "${VPPSB_PLUGINS[@]}"; do
    ln -sf "../vppsb/${PLUGIN}"
    ln -sf "../../../${PLUGIN}/turbotap.mk" "build-data/packages/"
    make "${MAKE_ARGS}" ${PLUGIN}-install
done
