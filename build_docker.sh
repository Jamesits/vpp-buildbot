#!/bin/bash
set -Eeuo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive
MAKE_ARGS="UNATTENDED=y V=${MAKE_VERBOSE} PLATFORM=${MAKE_PLATFORM} TAG=${MAKE_TAG} -j"
declare -a VPPSB_PLUGINS=(
	"netlink"
	"router"
	"turbotap"
    "flowtable"
    "vcl-ldpreload"
    "vhost-test"
    "vpp-bootstrap"
    "vpp-userdemo"
)

apt-get update -y
apt-get install -y git build-essential sudo python3

git clone "${GIT_VPP_URL}" "vpp"
git clone "${GIT_VPPSB_URL}" "vppsb"

cd vpp
git checkout "${VPP_BRANCH}"
make "${MAKE_ARGS}" install-dep
make "${MAKE_ARGS}" install-ext-deps
make "${MAKE_ARGS}" build-release
make "${MAKE_ARGS}" pkg-deb
make "${MAKE_ARGS}" vom-pkg-deb || true # known to fail

for PLUGIN in "${VPPSB_PLUGINS[@]}"; do
    ln -sf "../vppsb/${PLUGIN}"
    ln -sf "../../../${PLUGIN}/${PLUGIN}.mk" "build-data/packages/"
    make "${MAKE_ARGS}" ${PLUGIN}-install || echo "WARNING: ${PLUGIN} build failed!"
done
