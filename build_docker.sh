#!/bin/bash
set -Eeuo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive
MAKE_ARGS="UNATTENDED=y V=${MAKE_VERBOSE} PLATFORM=${MAKE_PLATFORM} TAG=${MAKE_TAG} -j"
declare -a VPPSB_PLUGINS=(
	"netlink"
	"router"
	"turbotap"
)
declare -a VPP_PLUGINS_INSTALL=(
    "sample-plugin"
    "netlink"
    "router"
    "turbotap"
)

apt-get update -y
apt-get install -y git build-essential sudo python3

git clone --recursive "${GIT_VPP_URL}" "vpp"
git clone --recursive "${GIT_VPPSB_URL}" "vppsb"

cd vpp
git checkout "${VPP_BRANCH}"

for PLUGIN in "${VPPSB_PLUGINS[@]}"; do
    # link necessary files in
    ln -sf "../vppsb/${PLUGIN}"
    ln -sf "../../../vppsb/${PLUGIN}/${PLUGIN}.mk" "build-data/packages/"
done

make ${MAKE_ARGS} install-dep
make ${MAKE_ARGS} bootstrap # only needed on old versions
make ${MAKE_ARGS} install-ext-deps
make ${MAKE_ARGS} build-release

for PLUGIN in "${VPP_PLUGINS_INSTALL[@]}"; do
    # build the plugin (let them fail)
    pushd build-root/
    make ${MAKE_ARGS} ${PLUGIN}-install || echo "WARNING: ${PLUGIN} build failed!"
    popd
done

make ${MAKE_ARGS} pkg-deb
make ${MAKE_ARGS} vom-pkg-deb || true # known to fail

# archive artifacts
# note that if $MAKE_TAG is empty, the directory is build-native and install-native
pushd build-root/
for DIRECTORY in "build-${MAKE_TAG}-native" "install-${MAKE_TAG}-native"; do
    tar -czf "${DIRECTORY}".tar.gz "${DIRECTORY}"
done
popd
